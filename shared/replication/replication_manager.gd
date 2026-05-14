extends Node

var tracked: Dictionary = {}   # int -> Replicable
var _next_id: int = 0

func register(entity: Replicable) -> void:
	entity.replication_id = _next_id
	tracked[_next_id] = entity
	_next_id += 1

func unregister(entity: Replicable) -> void:
	if entity.replication_id == -1:
		return

	tracked.erase(entity.replication_id)
	entity.replication_id = -1

func broadcast_snapshot() -> void:
	if tracked.is_empty():
		return

	var dirty_ids:  Array[int] = []
	var dirty_data: Array[PackedByteArray] = []

	for id in tracked:
		var entity: Replicable = tracked[id]
		if not entity.consume_dirty():
			continue

		var ebuf := StreamPeerBuffer.new()

		entity.serialize_into(ebuf)
		dirty_ids.append(id)
		dirty_data.append(ebuf.data_array)

	if dirty_ids.is_empty():
		return

	var packet := StreamPeerBuffer.new()
	
	packet.put_u8(PacketMgr.PacketType.REPLICATE)
	packet.put_u16(dirty_ids.size())

	for i in dirty_ids.size():
		packet.put_u16(dirty_ids[i])
		packet.put_u16(dirty_data[i].size())
		packet.put_data(dirty_data[i])

	for peer in Networking.connection.get_peers():
		Networking.send_packet(
			peer,
			Networking.Channel.REPLICATION,
			packet.data_array,
			ENetPacketPeer.FLAG_UNSEQUENCED
		)

func apply_snapshot(packet: StreamPeerBuffer) -> void:
	var count: int = packet.get_u16()

	for i in count:
		var id: int = packet.get_u16()
		var size: int = packet.get_u16()

		if tracked.has(id):
			tracked[id].deserialize_from(packet)
		else:
			packet.seek(packet.get_position() + size)
