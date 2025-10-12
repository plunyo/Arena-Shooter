extends Node

signal join_accepted

@onready var poll_timer: Timer = $PollTimer

var host: ENetConnection = ENetConnection.new()
var peer: ENetPacketPeer

var connected: bool = false
var username: String

func _ready() -> void:
	var err: Error = host.create_host()
	if err != OK:
		push_error("failed to create host")
		return

func connect_to_server(address: String, port: int, _username: String) -> void:
	if connected: return

	peer = host.connect_to_host(address, port, 2)
	if !peer:
		push_error("failed to connect to server")
		return

	username = _username

	print("connecting to server at %s:%d..." % [address, port])
	poll_timer.start()

func disconnect_from_server() -> void:
	if peer and not peer.is_active(): return
	peer.peer_disconnect()
	host.destroy()
	print("disconnected from server!")

func send_packet(packet: Packet, flag: int) -> void:
	var raw: PackedByteArray = packet.to_raw()
	peer.send(0, raw, flag)

func parse_packet(packet: PackedByteArray) -> void:
	var packet_id: int = packet.decode_u8(0)
	match packet_id:
		Packet.Server.JOIN_ACCEPT:
			print("join accepted!")
			join_accepted.emit()

func _on_poll_timer_timeout() -> void:
	var event: Array = host.service()
	var event_type: ENetConnection.EventType = event[0]
	var event_peer: ENetPacketPeer = event[1]

	match event_type:
		ENetConnection.EVENT_CONNECT:
			print("connected to server!")
			send_packet(Packet.new(Packet.Client.JOIN), ENetPacketPeer.FLAG_RELIABLE)
			connected = true

		ENetConnection.EVENT_DISCONNECT:
			disconnect_from_server()
			print("disconnected from server.")

		ENetConnection.EVENT_RECEIVE:
			var packet: PackedByteArray = event_peer.get_packet()
			parse_packet(packet)
