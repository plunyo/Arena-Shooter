extends Node

enum ConnectionState {
	DISCONNECTED,
	CONNECTING,
	CONNECTED
}

var connection: ENetConnection = ENetConnection.new()
var server_peer: ENetPacketPeer
var state: ConnectionState = ConnectionState.DISCONNECTED

func connect_to_server(ip: String, port: int) -> Error:
	if state != ConnectionState.DISCONNECTED:
		return ERR_ALREADY_IN_USE

	var err: Error = connection.create_host()
	if err != OK:
		return err

	server_peer = connection.connect_to_host(ip, port)
	if not is_instance_valid(server_peer):
		state = ConnectionState.DISCONNECTED
		return ERR_CANT_CONNECT

	state = ConnectionState.CONNECTING
	return OK

func _process(_delta: float) -> void:
	if state == ConnectionState.DISCONNECTED:
		return

	var event: Array = connection.service()
	var event_type: ENetConnection.EventType = event[0]
	var event_peer: ENetPacketPeer = event[1]

	match event_type:
		ENetConnection.EVENT_CONNECT:
			state = ConnectionState.CONNECTED
			print("CONNECTED TO SERVER!")
			send_string("hello digga")

		ENetConnection.EVENT_DISCONNECT:
			state = ConnectionState.DISCONNECTED
			server_peer = null
			print("DISCONNECTED!")

		ENetConnection.EVENT_RECEIVE:
			var packet := event_peer.get_packet()
			handle_packet(packet)

func send_string(message: String) -> void:
	if state != ConnectionState.CONNECTED:
		return

	server_peer.send(0, message.to_utf8_buffer(), ENetPacketPeer.FLAG_RELIABLE)

func handle_packet(packet: PackedByteArray) -> void:
	print(packet.get_string_from_utf8())
