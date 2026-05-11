extends Node

enum PacketType {
	# shared
	PING,

	# client
	MESSAGE,
	MOVE,

	# server
	REPLICATE
}

func create_packet(type: PacketType) -> StreamPeerBuffer:
	var packet := StreamPeerBuffer.new()

	packet.put_u8(type)

	return packet

func create_ping() -> PackedByteArray:
	var packet := create_packet(PacketType.PING)

	return packet.data_array

func send_packet(peer: ENetPacketPeer, channel: Networking.Channel) -> void:
	
