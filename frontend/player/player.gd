extends CharacterBody2D

const SPEED: float = 400.0

@onready var username_label: Label = $UsernameLabel

func _ready() -> void:
	username_label.text = ServerConnection.username

func _physics_process(_delta: float) -> void:
	var input_direction: Vector2 = Input.get_vector(&"left", &"right", &"up", &"down")
	var direction: Vector2 = input_direction.normalized()

	velocity = direction * SPEED
	move_and_slide()

func send_move_update() -> void:
	var payload: StreamPeerBuffer = StreamPeerBuffer.new() 
	payload.big_endian = true

	payload.put_float(global_position.x)
	payload.put_float(global_position.y)

	var packet: Packet = Packet.new(Packet.Client.MOVE, payload.data_array)
	ServerConnection.send_packet(packet, ENetPacketPeer.FLAG_UNRELIABLE_FRAGMENT)

func _on_update_timer_timeout() -> void:
	send_move_update()
