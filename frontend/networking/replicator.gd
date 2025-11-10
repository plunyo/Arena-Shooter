extends Node

func _ready() -> void:
	ServerConnection.packet_recieved.connect(_on_packet_recieved)

func _on_packet_recieved(packet: Packet) -> void:
	match packet.id:
		Packet.Server.1
