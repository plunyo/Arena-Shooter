class_name Client
extends Node

var client_id: int
var udp_conn: PacketPeerUDP
var tcp_conn: StreamPeerTCP

func _init(init_id: int, tcp_peer: StreamPeerTCP = null) -> void:
	client_id = init_id
	tcp_conn = tcp_peer
