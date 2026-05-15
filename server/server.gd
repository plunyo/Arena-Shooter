extends Control
class_name Server

const PORT := 7777

@onready var tick_timer: Timer = $TickTimer
@export var start_button: Button
@export var stop_button: Button
@export var run_info: RunInfo
@export var console: Console

var start_time: float = 0.0

var _peer_players: Dictionary = {}  # ENetPacketPeer -> PlayerState
var _next_replication_id:  int        = 0

class PlayerState:
	var replication_id: int
	var x:      float = 0.0
	var y:      float = 0.0
	var dirty:  bool  = true

func _ready() -> void:
	Networking.peer_connected.connect(_on_peer_connected)
	Networking.peer_disconnected.connect(_on_peer_disconnected)
	Networking.packet_received.connect(_on_packet_received)

func start_server() -> void:
	var err: Error = Networking.host_server(PORT)

	if err != OK:
		console.log_basic("Server failed to start!")
		return

	start_button.hide()
	stop_button.show()

	start_time = Time.get_ticks_msec() / 1000.0

	run_info.init_run_info(PORT, Networking.MAX_CLIENTS)

	console.log_basic("Server running on port %s!" % PORT)

	tick_timer.start()

func stop_server() -> void:
	Networking.close_connection()

	start_button.show()
	stop_button.hide()

	_peer_players.clear()

	console.log_basic("Server stopped!")

	tick_timer.stop()

func set_tickrate(new_tickrate: float) -> void:
	tick_timer.wait_time = 1.0 / new_tickrate

func _on_peer_connected(peer: ENetPacketPeer) -> void:
	var player: PlayerState = PlayerState.new()

	player.replication_id = _next_replication_id
	player.dirty = true
	_next_replication_id += 1
	_peer_players[peer] = player

	_send_spawn(PacketMgr.EntityType.PLAYER, player.replication_id, peer)
	_send_world_state_to(peer)

	console.log_basic("Player %d connected." % player.replication_id)

func _on_peer_disconnected(peer: ENetPacketPeer) -> void:
	if not _peer_players.has(peer):
		return

	var player: PlayerState = _peer_players[peer]

	_peer_players.erase(peer)
	_send_despawn(player.replication_id)

	console.log_basic("Player %d disconnected." % player.replication_id)

func _on_tick_timer_timeout() -> void:
	run_info.update_run_info(
		_peer_players.size(),
		int((Time.get_ticks_msec() / 1000.0) - start_time)
	)

	_broadcast_snapshot()

func _broadcast_snapshot() -> void:
	var dirty_players: Array = _peer_players.values().filter(
		func(p: PlayerState) -> bool: return p.dirty
	)

	if dirty_players.is_empty():
		return

	var packet := StreamPeerBuffer.new()

	packet.put_u8(PacketMgr.PacketType.REPLICATE)
	packet.put_u16(dirty_players.size())

	for player in dirty_players:
		packet.put_u16(player.replication_id)
		packet.put_float(player.x)
		packet.put_float(player.y)
		player.dirty = false

	var raw := packet.data_array
	for peer in _peer_players.keys():
		Networking.send_packet(peer, Networking.Channel.REPLICATION, raw, ENetPacketPeer.FLAG_UNSEQUENCED)

func _send_world_state_to(new_peer: ENetPacketPeer) -> void:
	var others: Array = _peer_players.values().filter(
		func(p: PlayerState) -> bool: return _peer_players.find_key(p) != new_peer
	)

	if others.is_empty():
		return

	var packet := StreamPeerBuffer.new()

	packet.put_u8(PacketMgr.PacketType.REPLICATE)
	packet.put_u16(others.size())

	for player in others:
		packet.put_u16(player.replication_id)
		packet.put_float(player.x)
		packet.put_float(player.y)

	Networking.send_packet(new_peer, Networking.Channel.RELIABLE, packet.data_array)

func _send_spawn(entity_type: PacketMgr.EntityType, replication_id: int, exclude: ENetPacketPeer = null) -> void:
	var packet := StreamPeerBuffer.new()

	packet.put_u8(PacketMgr.PacketType.SPAWN)
	packet.put_u8(entity_type)
	packet.put_u16(replication_id)

	var raw := packet.data_array
	for peer in _peer_players.keys():
		if peer == exclude:
			continue

		Networking.send_packet(peer, Networking.Channel.RELIABLE, raw)

func _send_despawn(replication_id: int) -> void:
	var packet := StreamPeerBuffer.new()
	packet.put_u8(PacketMgr.PacketType.DESPAWN)
	packet.put_u16(replication_id)
	var raw := packet.data_array
	for peer in _peer_players.keys():
		Networking.send_packet(peer, Networking.Channel.RELIABLE, raw)

# ─── Packet Handler ───────────────────────────────────────────────────────────

func _on_packet_received(peer: ENetPacketPeer, packet_data: PackedByteArray) -> void:
	var packet: StreamPeerBuffer = PacketMgr.read_packet(packet_data)
	var type: PacketMgr.PacketType = packet.get_u8() as PacketMgr.PacketType
	match type:
		PacketMgr.PacketType.MOVE:
			_handle_move(peer, packet)

func _handle_move(peer: ENetPacketPeer, packet: StreamPeerBuffer) -> void:
	if not _peer_players.has(peer):
		return
	var player: PlayerState = _peer_players[peer]
	player.x     = packet.get_float()
	player.y     = packet.get_float()
	player.dirty = true
