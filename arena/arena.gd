extends Node2D


func _ready() -> void:
	ReplicationMgr.entity_roots[ReplicationMgr.EntityType.PLAYER] = self
