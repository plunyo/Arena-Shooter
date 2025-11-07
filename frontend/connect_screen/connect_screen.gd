extends Control

const ERROR_MESSAGE_SCENE: PackedScene = preload("uid://k12a7effdqt1")

@export var ip_line_edit: LineEdit
@export var port_line_edit: LineEdit

@onready var username_line_edit: LineEdit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/UsernameLineEdit
@onready var error_message_container: VBoxContainer = $ErrorMessageContainer
@onready var status_label: Label = $StatusLabel

func _ready() -> void:
	ServerConnection.connected_to_server.connect(_on_connected_to_server)

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

	ServerConnection.connect_to_server(ip, port, username_line_edit.text)

func _on_connected_to_server() -> void:
	ServerConnection.send_packet(Packet.new(Packet.Client.JOIN), ENetPacketPeer.FLAG_RELIABLE)
