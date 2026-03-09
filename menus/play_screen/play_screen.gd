extends Control


func _on_client_button_pressed() -> void:
	pass # Replace with function body.


func _on_server_button_pressed() -> void:
	get_tree().change_scene_to_file("res://server/server.tscn")
