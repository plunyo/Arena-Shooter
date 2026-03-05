extends Control
class_name Server

var server: ENetConnection

const PORT := 7777
const MAX_CLIENTS := 32

func _ready() -> void:
	server = ENetConnection.new()

	# create host
	var err = server.create_host_bound("*", PORT, MAX_CLIENTS)
	if err != OK:
		print("server failed")
		return

	print("server running on port", PORT)

func _process(_delta: float) -> void:
	server.service()

	# process events
	while server.get_event_count() > 0:
		var event = server.pop_event()

		match event.type:
			ENetConnection.EVENT_CONNECT:
				print("client connected")

			ENetConnection.EVENT_DISCONNECT:
				print("client disconnected")

			ENetConnection.EVENT_RECEIVE:
				var data = event.packet.get_data()
				print("received:", data.get_string_from_utf8())
