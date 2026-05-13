class_name Replicable
extends Node

var replication_id: int = -1
var _dirty: bool = true

func serialize_into(buf: StreamPeerBuffer) -> void:
	pass

func deserialize_from(buf: StreamPeerBuffer) -> void:
	pass

func mark_dirty() -> void:
	_dirty = true

func consume_dirty() -> bool:
	if not _dirty:
		return false

	_dirty = false
	return true
