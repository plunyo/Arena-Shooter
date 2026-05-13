extends Replicable

@onready var player: Player = get_parent()

func serialize_into(buf: StreamPeerBuffer) -> void:
	buf.put_float(player.position.x)
	buf.put_float(player.position.y)

func deserialize_from(buf: StreamPeerBuffer) -> void:
	player.position.x = buf.get_float()
	player.position.y = buf.get_float()
