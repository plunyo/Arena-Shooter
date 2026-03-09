extends Control
class_name Server

enum { EVENT_TYPE, EVENT_PEER, EVENT_DATA, EVENT_CHANNEL }

@export var console: Console

var server: ENetConnection

const PORT := 7777
const MAX_CLIENTS := 32

func _ready() -> void:
	server = ENetConnection.new()

	var err = server.create_host_bound("*", PORT, MAX_CLIENTS)
	if err != OK:
		console.log_basic("Server failed.")
		return

	console.log_basic("Server running on port: " + str(PORT))

func _process(_delta: float) -> void:
	var event = server.service()

	match event[EVENT_TYPE]:
		ENetConnection.EVENT_CONNECT:
			console.log_basic("Client Connected!")

		ENetConnection.EVENT_DISCONNECT:
			console.log_basic("Client Disconnected!")

		ENetConnection.EVENT_RECEIVE:
			var data = event.packet.get_data()
			console.log_basic("Received: " + data.get_string_from_utf8())
