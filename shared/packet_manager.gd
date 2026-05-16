extends Node

enum PacketType {
	MESSAGE,
	MOVE,
	REPLICATE,
	SPAWN,
	DESPAWN
}

func create_packet(type: PacketType) -> StreamPeerBuffer:
	var packet := StreamPeerBuffer.new()

	packet.put_u8(type)

	return packet

func create_spawn_packet(entity_type: ReplicationMgr.EntityType, replication_id: int) -> StreamPeerBuffer:
	var packet := create_packet(PacketType.SPAWN)

	packet.put_u8(entity_type)
	packet.put_u16(replication_id)

	return packet

func create_despawn(replication_id: int) -> StreamPeerBuffer:
	var packet := create_packet(PacketType.DESPAWN)

	packet.put_u16(replication_id)

	return packet

func read_packet(data: PackedByteArray) -> StreamPeerBuffer:
	var packet := StreamPeerBuffer.new()

	packet.data_array = data

	return packet
