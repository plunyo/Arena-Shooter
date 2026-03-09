extends VBoxContainer
class_name Console

const BASIC_LOG_SCENE: PackedScene = preload("res://server/console/logs/basic_log.tscn")

func log_basic(text: String) -> void:
	var log_instance: BasicLog = BASIC_LOG_SCENE.instantiate() as BasicLog
	add_child(log_instance)
	log_instance.set_text(text)
