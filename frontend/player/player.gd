extends CharacterBody2D

const SPEED: float = 400.0

@onready var username_label: Label = $UsernameLabel

var id: int
var local_player: bool
var move_buffer: StreamPeerBuffer = StreamPeerBuffer.new()

func _ready() -> void:
	local_player = ServerConnection.id == id
	username_label.text = ServerConnection.username
	ServerConnection.request_replicate()

	move_buffer.big_endian = true

func _physics_process(_delta: float) -> void:
	var input_direction := Input.get_vector("left", "right", "up", "down")
	velocity = input_direction.normalized() * SPEED
	move_and_slide()

func send_move_update() -> void:
	move_buffer.clear()
	move_buffer.put_float(global_position.x)
	move_buffer.put_float(global_position.y)

	var packet := Packet.new(Packet.Client.MOVE, move_buffer.data_array)
	ServerConnection.send_packet(packet, ENetPacketPeer.FLAG_UNRELIABLE_FRAGMENT)

func _on_update_timer_timeout() -> void:
	send_move_update()
