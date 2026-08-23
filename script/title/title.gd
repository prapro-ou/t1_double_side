extends Node2D

@onready var host_button = $UILayer/Control/HostButton
@onready var join_button = $UILayer/Control/JoinButton

func _on_host_button_pressed() -> void:
	NetworkManager.is_host = true;
	DecidedSePlayer.play()
	SceneManager.change_scene("lobby")


func _on_join_button_pressed() -> void:
	NetworkManager.is_host = false;
	DecidedSePlayer.play()
	SceneManager.change_scene("lobby")


func _on_how_to_play_button_pressed() -> void:
	pass # Replace with function body.


func _on_credit_button_pressed() -> void:
	DecidedSePlayer.play()
	SceneManager.change_scene("credit")
