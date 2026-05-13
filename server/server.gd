extends Control
class_name Server

const PORT := 7777

@onready var tick_timer: Timer = $TickTimer

@export var start_button: Button
@export var stop_button: Button
@export var run_info: RunInfo
@export var console: Console

var start_time: float = 0.0

func _ready() -> void:
	if not Networking.peer_connected.is_connected(_on_peer_connected):
		Networking.peer_connected.connect(_on_peer_connected)

	if not Networking.peer_disconnected.is_connected(_on_peer_disconnected):
		Networking.peer_disconnected.connect(_on_peer_disconnected)

	if not Networking.packet_received.is_connected(_on_packet_received):
		Networking.packet_received.connect(_on_packet_received)

func start_server() -> void:
	var err := Networking.host_server(PORT)
	if err != OK:
		console.log_basic("server failed!")
		return

	start_button.hide()
	stop_button.show()

	start_time = Time.get_ticks_msec() / 1000.0

	run_info.init_run_info(PORT, Networking.MAX_CLIENTS)
	console.log_basic("server running on port %s!" % PORT)

	tick_timer.start()

func stop_server() -> void:
	Networking.close_connection()

	start_button.show()
	stop_button.hide()

	console.log_basic("server stopped!")
	tick_timer.stop()

func set_tickrate(new_tickrate: float) -> void:
	tick_timer.wait_time = 1.0 / new_tickrate

func _on_tick_timer_timeout() -> void:
	run_info.update_run_info(
		Networking.connection.get_peers().size(),
		int((Time.get_ticks_msec() / 1000.0) - start_time)
	)

func _on_peer_connected(_peer: ENetPacketPeer) -> void:
	console.log_basic("client connected!")

func _on_peer_disconnected(_peer: ENetPacketPeer) -> void:
	console.log_basic("client disconnected!")

func _on_packet_received(_peer: ENetPacketPeer, packet_data: PackedByteArray) -> void:
	var packet := PacketMgr.read_packet(packet_data)
	var type := packet.get_u8() as PacketMgr.PacketType

	match type:
		PacketMgr.PacketType.MESSAGE:
			pass

		PacketMgr.PacketType.MOVE:
			pass

		PacketMgr.PacketType.REPLICATE:
			pass
