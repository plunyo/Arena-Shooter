extends Control
class_name Server

const PORT := 7777
const MAX_CLIENTS := 32

@onready var tick_timer: Timer = $TickTimer

@export var start_button: Button
@export var stop_button: Button
@export var run_info: RunInfo
@export var console: Console

var server: ENetConnection
var start_time: float

func start_server() -> void:
	start_button.hide()
	stop_button.show()

	server = ENetConnection.new()

	var err = server.create_host_bound("*", PORT, MAX_CLIENTS)
	if err != OK:
		console.log_basic("Server failed.")
		return

	start_time = Time.get_ticks_msec() / 1000.0
	run_info.init_run_info(PORT, MAX_CLIENTS)
	console.log_basic("Server running on port: " + str(PORT))

	tick_timer.start()

func stop_server() -> void:
	if server:
		start_button.show()
		stop_button.hide()

		server.destroy()
		console.log_basic("Server stopped")
		tick_timer.stop()
		server = null

func set_tickrate(new_tickrate: float) -> void:
	tick_timer.wait_time = 1 / new_tickrate

func _on_tick_timer_timeout() -> void:
	run_info.update_run_info(
		server.get_peers().size(),
		int((Time.get_ticks_msec() / 1000.0) - start_time)
	)

	var event = server.service()
	var event_type: ENetConnection.EventType = event[0]
	var event_peer: ENetPacketPeer = event[1]

	match event_type:
		ENetConnection.EVENT_CONNECT:
			console.log_basic("Client Connected!")

		ENetConnection.EVENT_DISCONNECT:
			console.log_basic("Client Disconnected!")

		ENetConnection.EVENT_RECEIVE:
			console.log_basic("Received: " + event_peer.get_packet().get_string_from_utf8() + ", from " + event_peer.get_remote_address())
