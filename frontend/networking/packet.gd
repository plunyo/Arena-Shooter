class_name Packet
extends Node

enum Client {
	JOIN = 0x00,
	MOVE = 0x01,
	REQUEST_REPLICATE = 0x02,
	KICK_PLAYER = 0x03,
	LEAVE = 0x04,
	REQUEST_SESSION_ID = 0x05,
}

enum Server {
	JOIN_ACCEPT = 0x00,
	JOIN_DENY = 0x01,
	REPLICATE = 0x02,
	SYNC_PLAYERS = 0x03, 
	KICK_PLAYER = 0x04,
	CLIENT_ID = 0x05,
	SESSION_ID = 0x06
}

var id: int
var data: PackedByteArray

func _init(_id: int, _data: PackedByteArray = PackedByteArray()) -> void:
	id = _id
	data = _data

func to_raw() -> PackedByteArray:
	var buffer: StreamPeerBuffer = StreamPeerBuffer.new()
	buffer.big_endian = true
	buffer.put_u8(id)
	buffer.put_data(data)
	return buffer.data_array

static func from_raw(raw: PackedByteArray) -> Packet:
	var buffer = StreamPeerBuffer.new()

	buffer.big_endian = true
	buffer.data_array = raw
	buffer.seek(0)

	var new_id: int = buffer.get_u8()
	var new_data: PackedByteArray = PackedByteArray()

	new_data.resize(buffer.get_available_bytes())
	new_data.append_array(buffer.get_data(buffer.get_available_bytes()))

	return Packet.new(new_id, new_data)
