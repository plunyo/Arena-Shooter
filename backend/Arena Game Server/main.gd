extends Node

const PORT: int = 30067

var tcp_server: TCPServer = TCPServer.new()
var udp_server: UDPServer = UDPServer.new()
var clients: Array[Client] = []
var client_count: int = 0

func _ready() -> void:
	tcp_server.listen(PORT)
	udp_server.listen(PORT)

func _on_tick_rate_timer_timeout() -> void:
	udp_server.poll()

	# handle new connections
	if tcp_server.is_connection_available():
		var tcp_peer: StreamPeerTCP = tcp_server.take_connection()
		clients.append(Client.new(client_count, tcp_peer))
		client_count += 1
