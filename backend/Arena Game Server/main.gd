extends Node

const PORT: int = 30067

var server: TCPServer = TCPServer.new()
var clients: Array[StreamPeerTCP] = Array()

func _ready() -> void:
	server.listen(PORT)

func _process(delta: float) -> void:
	# handle new connections
	if server.is_connection_available():
		var client: StreamPeerTCP = server.take_connection()
