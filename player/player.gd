class_name Player
extends CharacterBody2D

@onready var replicable: Replicable = $Replicable

var last_position: Vector2

func _ready() -> void:
	last_position = global_position

func _physics_process(_delta: float) -> void:
	if last_position != global_position: # if its moved
		last_position = global_position
		replicable.mark_dirty()

	

	move_and_slide()
