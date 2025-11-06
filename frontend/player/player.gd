extends CharacterBody2D

const SPEED: float = 400.0

func _physics_process(_delta: float) -> void:
	var input_direction: Vector2 = Input.get_vector(&"left", &"right", &"up", &"down")
	var direction: Vector2 = input_direction.normalized()

	velocity = direction * SPEED
	move_and_slide()

func send_player_update() -> void:
	var payload: StreamPeerBuffer = StreamPeerBuffer.new()
	payload.put_float(global_position.x)
	payload.put_float(global_position.y)

	var packet: Packet = Packet.new(Packet.Server.UPDATE_PLAYERS, payload.data_array)
	ServerConnection.send_packet(packet, ENetPacketPeer.FLAG_UNRELIABLE_FRAGMENT)

func _on_update_timer_timeout() -> void:
	send_player_update()
