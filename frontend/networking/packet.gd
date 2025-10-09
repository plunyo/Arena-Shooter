class_name Packet
extends Object

enum Client {
	JOIN = 0x00,
	MOVE = 0x01,
	REQUEST_PLAYER_SYNC = 0x02,
	KICK_PLAYER = 0x03,
	LEAVE = 0x04,
	REQUEST_SESSION_ID = 0x05,
}
enum Server {
	JOIN_ACCEPT = 0x00,
	JOIN_DENY = 0x01,
	UPDATE_PLAYERS = 0x02,
	SYNC_PLAYERS = 0x03, 
	KICK_PLAYER = 0x04,
	CLIENT_ID = 0x05,
	SESSION_ID = 0x06
}

var id: int = -1
var data: Variant = null

func _init(_id: int, _data: Variant = null) -> void:
	self.id = _id
	self.data = _data
