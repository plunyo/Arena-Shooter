extends Control
class_name Server

enum { EVENT_TYPE, EVENT_PEER, EVENT_DATA, EVENT_CHANNEL }

const PORT := 7777
const MAX_CLIENTS := 32

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

func stop_server() -> void:
	if server:
		start_button.show()
		stop_button.hide()

		server.destroy()
		console.log_basic("Server stopped")
		server = null

func _on_tick_timer_timeout() -> void:
	run_info.update_run_info(
		server.get_peers().size(),
		int((Time.get_ticks_msec() / 1000.0) - start_time)
	)

	var event = server.service()

	match event[EVENT_TYPE]:
		ENetConnection.EVENT_CONNECT:
			console.log_basic("Client Connected!")

		ENetConnection.EVENT_DISCONNECT:
			console.log_basic("Client Disconnected!")

		ENetConnection.EVENT_RECEIVE:
			var data = event.packet.get_data()
			console.log_basic("Received: " + data.get_string_from_utf8())
