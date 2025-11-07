extends Node

signal join_accepted
signal connected_to_server

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
	if peer != null and not peer.is_active(): return
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
			get_tree().change_scene_to_file("res://arena/arena.tscn")

func _on_poll_timer_timeout() -> void:
	var event: Array = host.service()
	var event_type: ENetConnection.EventType = event[0]
	var event_peer: ENetPacketPeer = event[1]

	match event_type:
		ENetConnection.EVENT_CONNECT:
			connected_to_server.emit()
			print("connected to server!")
			connected = true

		ENetConnection.EVENT_DISCONNECT:
			disconnect_from_server()
			print("disconnected from server.")

		ENetConnection.EVENT_RECEIVE:
			var packet: PackedByteArray = event_peer.get_packet()
			parse_packet(packet)

func _on_tree_exiting() -> void:
	disconnect_from_server()
