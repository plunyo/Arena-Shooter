extends Node

var tracked: Dictionary = {}   # int -> Replicable
var _next_id: int = 0
var _tick: int = 0


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

	_tick += 1

	var peers: Array[ENetPacketPeer] = Networking.connection.get_peers()

	for peer in peers:
		var packet := StreamPeerBuffer.new()

		packet.put_u8(PacketMgr.PacketType.REPLICATE)
		packet.put_u32(_tick)

		var entity_count_pos := packet.get_position()
		packet.put_u16(0)

		var entity_count := 0

		for id in tracked:
			var entity: Replicable = tracked[id]

			if not entity.consume_dirty():
				continue

			if entity.owner_peer_id == peer:
				continue

			var ebuf := StreamPeerBuffer.new()
			entity.serialize_into(ebuf)

			packet.put_u16(id)
			packet.put_u16(ebuf.data_array.size())
			packet.put_data(ebuf.data_array)

			entity_count += 1

		if entity_count == 0:
			continue

		var end_pos: int = packet.get_position()

		packet.seek(entity_count_pos)
		packet.put_u16(entity_count)
		packet.seek(end_pos)

		Networking.send_packet(
			peer,
			Networking.Channel.REPLICATION,
			packet.data_array,
			ENetPacketPeer.FLAG_UNSEQUENCED
		)

func apply_snapshot(packet: StreamPeerBuffer) -> void:
	var _snapshot_tick: int = packet.get_u32()
	var count: int = packet.get_u16()

	for i in count:
		var id: int = packet.get_u16()
		var size: int = packet.get_u16()

		if tracked.has(id):
			tracked[id].deserialize_from(packet)
		else:
			packet.seek(packet.get_position() + size)
