extends Node

enum PacketType {
	MESSAGE,
	MOVE,
	REPLICATE,
	SPAWN,
	DESPAWN
}
# make entity type and entity root enums
func create_packet(type: PacketType) -> StreamPeerBuffer:
	var packet := StreamPeerBuffer.new()

	packet.put_u8(type)

	return packet

func read_packet(data: PackedByteArray) -> StreamPeerBuffer:
	var packet := StreamPeerBuffer.new()

	packet.data_array = data

	return packet
