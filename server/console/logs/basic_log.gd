extends ConsoleLog
class_name BasicLog

@onready var label: Label = $MarginContainer/Label

func _ready() -> void:
	label.text = _get_time()

func set_text(text: String) -> void:
	label.text = _get_time() + text

func _get_time() -> String:
	var dt := Time.get_datetime_dict_from_system()
	return "[%02d:%02d:%02d] " % [dt.hour, dt.minute, dt.second]
