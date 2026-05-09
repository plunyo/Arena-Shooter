extends Control

@onready var username_line_edit: LineEdit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/UsernameLineEdit

func _on_join_button_pressed() -> void:
	ClientConn.connect_to_server("localhost", 7777)
