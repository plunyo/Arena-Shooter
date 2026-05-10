extends Control

@onready var username_line_edit: LineEdit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/UsernameLineEdit
@onready var address_line_edit: LineEdit = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/AddressLineEdit

func _on_join_button_pressed() -> void:
	var address: String = address_line_edit.text if not address_line_edit.text.is_empty() else address_line_edit.placeholder_text

	var split_address: PackedStringArray = address.split(":")

	var ip: String = split_address[0]
	var port: int = int(split_address[1])

	ClientConn.connect_to_server(ip, port)
