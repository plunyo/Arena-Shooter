extends Node

@onready var poll_timer: Timer = $PollTimer

var socket: StreamPeerTCP = StreamPeerTCP.new()

func connect_to_server(host: String, port: int) -> void:
	var error: Error = socket.connect_to_host(host, port)
	if error != OK:
		print("could not connect to %s:%d" % [host, port])

	poll_timer.start()

func _on_poll_timer_timeout() -> void:
	match socket.get_status():
		StreamPeerTCP.STATUS_CONNECTING:
			print("connecting...")
		StreamPeerTCP.STATUS_CONNECTED:
			print("connected!")
		StreamPeerTCP.STATUS_ERROR:
			print("something went wrong :/")
