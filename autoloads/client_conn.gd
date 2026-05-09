extends Node

var connection: ENetConnection = ENetConnection.new()
var server_peer: ENetPacketPeer

func connect_to_server(ip: String, port: int) -> Error:
	var err: Error = connection.create_host()
	if err != OK:
		return err

	server_peer = connection.connect_to_host(ip, port)
	return err

func _process(_delta: float) -> void:
	if not is_instance_valid(server_peer): return

	var event: Array = connection.service()
	var event_type: ENetConnection.EventType = event[0]
	var event_peer: ENetPacketPeer = event[1]

	match event_type:
		ENetConnection.EVENT_CONNECT:
			print("connected")
			send_string("hello digga")

		ENetConnection.EVENT_DISCONNECT:
			print("disconnected")

		ENetConnection.EVENT_RECEIVE:
			var packet := event_peer.get_packet()

			handle_packet(packet)

func send_string(message: String) -> void:
	server_peer.send(0, message.to_utf8_buffer(), ENetPacketPeer.FLAG_RELIABLE)

func handle_packet(packet: PackedByteArray) -> void:
	print(packet.get_string_from_utf8())
