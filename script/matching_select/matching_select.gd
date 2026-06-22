extends Node2D

@onready var host_button = $UILayer/Control/HostButton
@onready var join_button = $UILayer/Control/JoinButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_host_button_pressed() -> void:
	NetworkManager.is_host = true;
	SceneManager.change_scene("lobby")


func _on_join_button_pressed() -> void:
	NetworkManager.is_host = false;
	SceneManager.change_scene("lobby")
