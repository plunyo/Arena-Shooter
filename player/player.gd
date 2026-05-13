class_name Player
extends CharacterBody2D

@onready var replicable: Replicable = $Replicable

func _physics_process(_delta: float) -> void:
	if velocity != Vector2.ZERO:
		replicable.mark_dirty()

	move_and_slide()
