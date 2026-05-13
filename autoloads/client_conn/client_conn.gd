extends Node

func _ready() -> void:
	if not Networking.connected.is_connected(_on_connected):
		Networking.connected.connect(_on_connected)

	if not Networking.disconnected.is_connected(_on_disconnected):
		Networking.disconnected.connect(_on_disconnected)

	if not Networking.packet_received.is_connected(_on_packet_received):
		Networking.packet_received.connect(_on_packet_received)

func connect_to_server(ip: String, port: int) -> void:
	var err := Networking.connect_to_server(ip, port)
	if err != OK:
		print("failed to connect: ", err)

func _process(_delta: float) -> void:
	if Networking.state != Networking.ConnectionState.CONNECTED:
		return

func print_ping() -> void:
	var rtt := Networking.get_round_trip_time()
	print("ping: ", rtt, "ms")

func _on_connected() -> void:
	print("connected to server")

func _on_disconnected() -> void:
	print("disconnected from server")

func _on_packet_received(_peer: ENetPacketPeer, packet_data: PackedByteArray) -> void:
	var packet := PacketMgr.read_packet(packet_data)
	var type := packet.get_u8() as PacketMgr.PacketType

	match type:
		PacketMgr.PacketType.MESSAGE:
			pass

		PacketMgr.PacketType.MOVE:
			pass

		PacketMgr.PacketType.REPLICATE:
			pass
