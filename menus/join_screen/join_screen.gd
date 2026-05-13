extends Control

@onready var username_line_edit: LineEdit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/UsernameLineEdit
@onready var address_line_edit: LineEdit = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/AddressLineEdit

func _on_join_button_pressed() -> void:
	var address: String = address_line_edit.text
	if address.is_empty():
		address = address_line_edit.placeholder_text

	var split_address: PackedStringArray = address.split(":")

	if split_address.size() < 2:
		print("failed to connect: invalid address format")
		return

	var ip: String = split_address[0]
	var port: int = int(split_address[1])

	var err := Networking.connect_to_server(ip, port)
	if err != OK:
		print("failed to connect: ", err)
