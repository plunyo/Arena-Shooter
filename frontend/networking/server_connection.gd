extends Node

enum EventIndex { TYPE, PEER, DATA, CHANNEL }

@onready var poll_timer: Timer = $PollTimer

var host: ENetConnection = ENetConnection.new()
var peer: ENetPacketPeer

var connected: bool = false

func _ready() -> void:
	var err: Error = host.create_host()
	if err != OK:
		push_error("failed to create host")
		return

func connect_to_server(address: String, port: int) -> void:
	if connected: return

	peer = host.connect_to_host(address, port)
	if !peer:
		push_error("failed to connect to server")
		return

	print("connecting to server at %s:%d..." % [address, port])
	poll_timer.start()

func disconnect_from_server() -> void:
	if peer and not peer.is_active(): return
	peer.peer_disconnect()
	host.destroy()
	print("disconnected from server!")

func _on_poll_timer_timeout() -> void:
	var event: Array = host.service()

	match event[EventIndex.TYPE]:
		ENetConnection.EVENT_CONNECT:
			print("connected to server!")
			connected = true
		ENetConnection.EVENT_RECEIVE:
			var packet = event[EventIndex.DATA]
			print("received packet:", packet.get_string())
		ENetConnection.EVENT_DISCONNECT:
			print("disconnected from server.")
