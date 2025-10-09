extends Node

const PORT: int = 30067

var tcp_server: TCPServer = TCPServer.new()
var clients: Array[Client] = []
var client_count: int = 0

func _ready() -> void:
	tcp_server.listen(PORT)

func _on_tick_rate_timer_timeout() -> void:
	# handle new connections
	if tcp_server.is_connection_available():
		var client: Client = Client.new(client_count, tcp_server.take_connection())
		client_count += 1
		clients.append(client)

		client.tcp_conn.put_var(Packet.new(Packet.Server.JOIN_ACCEPT))
