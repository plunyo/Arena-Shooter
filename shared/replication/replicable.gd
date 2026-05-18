class_name Replicable
extends Node

var owner_peer_id: int = -1

var replication_id: int = -1
var _dirty: bool = true

func serialize_into(_buf: StreamPeerBuffer) -> void:
	pass

func deserialize_from(_buf: StreamPeerBuffer) -> void:
	pass

func mark_dirty() -> void:
	_dirty = true

func consume_dirty() -> bool:
	if not _dirty:
		return false

	_dirty = false
	return true

func is_local_owner() -> bool:
	return owner_peer_id == Networking.local_peer_id
