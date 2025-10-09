extends Control

const ERROR_MESSAGE_SCENE: PackedScene = preload("uid://k12a7effdqt1")

@export var ip_line_edit: LineEdit
@export var port_line_edit: LineEdit

@onready var error_message_container: VBoxContainer = $ErrorMessageContainer
@onready var status_label: Label = $StatusLabel

func _on_button_pressed() -> void:
	var ip: String = ip_line_edit.text.strip_edges()
	var port_str: String = port_line_edit.text.strip_edges()

	if ip == "":
		ip = ip_line_edit.placeholder_text

	if port_str == "":
		port_str = port_line_edit.placeholder_text

	var port: int
	if port_str.is_valid_int():
		port = int(port_str)
	else:
		port = 30067

	ServerConnection.connect_to_server(ip, port)

func _on_recieved_packet(packet_id: int, _data: PackedByteArray) -> void:
	if packet_id != Packet.Server.JOIN_ACCEPT: return
	get_tree().change_scene_to_file("res://arena/arena.tscn")

func _on_server_connection_connected() -> void:
	ServerConnection.send_packet(
		ServerConnection.TCP,
		Packet.Client.REQUEST_SESSION_ID
	)
