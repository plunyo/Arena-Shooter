extends Node

@onready var ping_timer: Timer = $PingTimer

# Which scene to instantiate per entity type — add new types here as you go
var entity_scenes: Dictionary = {
	PacketMgr.EntityType.PLAYER: preload("res://player/player.tscn"),
}

# Point this at whatever node should parent spawned entities in your scene tree
@export var world: Node

func _ready() -> void:
	Networking.connected.connect(_on_connected)
	Networking.disconnected.connect(_on_disconnected)
	Networking.packet_received.connect(_on_packet_received)

func connect_to_server(ip: String, port: int) -> void:
	var err: Error = Networking.connect_to_server(ip, port)
	if err != OK:
		print("Failed to connect: ", err)

func print_ping() -> void:
	print("Ping: ", Networking.get_round_trip_time(), "ms")

func _on_connected() -> void:
	ping_timer.start()
	print("Connected!")

func _on_disconnected() -> void:
	ping_timer.stop()
	ReplicationMgr.clear()
	print("Disconnected!")

# ─── Packet Handler ───────────────────────────────────────────────────────────

func _on_packet_received(_peer: ENetPacketPeer, packet_data: PackedByteArray) -> void:
	var packet: StreamPeerBuffer = PacketMgr.read_packet(packet_data)
	var type: PacketMgr.PacketType = packet.get_u8() as PacketMgr.PacketType

	match type:
		PacketMgr.PacketType.REPLICATE:
			ReplicationMgr.apply_snapshot(packet)
		PacketMgr.PacketType.SPAWN:
			_handle_spawn(packet)
		PacketMgr.PacketType.DESPAWN:
			_handle_despawn(packet)

func _handle_spawn(packet: StreamPeerBuffer) -> void:
	var entity_type: PacketMgr.EntityType = packet.get_u8() as PacketMgr.EntityType
	var rep_id: int = packet.get_u16()

	if not entity_scenes.has(entity_type):
		push_error("Unknown EntityType: %d" % entity_type)
		return

	var entity: Node = entity_scenes[entity_type].instantiate()
	var root: Node   = world if is_instance_valid(world) else self
	root.add_child(entity)

	var replicable: Replicable = entity.get_node("Replicable")
	replicable.replication_id  = rep_id
	ReplicationMgr.tracked[rep_id] = replicable

func _handle_despawn(packet: StreamPeerBuffer) -> void:
	var rep_id := packet.get_u16()
	if not ReplicationMgr.tracked.has(rep_id):
		return

	var replicable: Replicable = ReplicationMgr.tracked[rep_id]
	ReplicationMgr.unregister(replicable)
	replicable.get_parent().queue_free()
