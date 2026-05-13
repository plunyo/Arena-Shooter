extends Node

enum ConnectionState {
	DISCONNECTED,
	CONNECTING,
	CONNECTED
}

enum Channel {
	RELIABLE,
	UNRELIABLE,
	REPLICATION
}

signal connected
signal disconnected
signal peer_connected(peer: ENetPacketPeer)
signal peer_disconnected(peer: ENetPacketPeer)
signal packet_received(peer: ENetPacketPeer, packet: PackedByteArray)

const MAX_CLIENTS := 32

var connection := ENetConnection.new()
var server_peer: ENetPacketPeer = null

var state := ConnectionState.DISCONNECTED
var is_server := false

func _reset_connection() -> void:
	connection = ENetConnection.new()
	server_peer = null

func host_server(port: int) -> Error:
	if state != ConnectionState.DISCONNECTED:
		return ERR_ALREADY_IN_USE

	_reset_connection()

	var err := connection.create_host_bound("*", port, MAX_CLIENTS)
	if err != OK:
		return err

	is_server = true
	state = ConnectionState.CONNECTED

	return OK

func connect_to_server(ip: String, port: int) -> Error:
	if state != ConnectionState.DISCONNECTED:
		return ERR_ALREADY_IN_USE

	_reset_connection()

	var err := connection.create_host()
	if err != OK:
		return err

	server_peer = connection.connect_to_host(ip, port)

	if not is_instance_valid(server_peer):
		return ERR_CANT_CONNECT

	is_server = false
	state = ConnectionState.CONNECTING

	return OK

func close_connection() -> void:
	if state == ConnectionState.DISCONNECTED:
		return

	_reset_connection()
	state = ConnectionState.DISCONNECTED
	is_server = false
	disconnected.emit()

func send_packet(peer: ENetPacketPeer, channel_id: Channel, data: PackedByteArray, flags: int = ENetPacketPeer.FLAG_RELIABLE) -> void:
	if not is_instance_valid(peer):
		return

	peer.send(channel_id, data, flags)

func get_round_trip_time() -> float:
	if not is_instance_valid(server_peer):
		return -1

	return server_peer.get_statistic(ENetPacketPeer.PEER_LAST_ROUND_TRIP_TIME)

func _process(_delta: float) -> void:
	if state == ConnectionState.DISCONNECTED:
		return

	while true:
		var event := connection.service()

		var event_type: ENetConnection.EventType = event[0]
		if event_type == ENetConnection.EVENT_NONE:
			break

		var event_peer: ENetPacketPeer = event[1]

		match event_type:
			ENetConnection.EVENT_CONNECT:
				if is_server:
					peer_connected.emit(event_peer)
				else:
					state = ConnectionState.CONNECTED
					connected.emit()

			ENetConnection.EVENT_DISCONNECT:
				if is_server:
					peer_disconnected.emit(event_peer)
				else:
					state = ConnectionState.DISCONNECTED
					server_peer = null
					disconnected.emit()

			ENetConnection.EVENT_RECEIVE:
				packet_received.emit(event_peer, event_peer.get_packet())
