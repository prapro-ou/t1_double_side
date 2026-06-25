extends Control

@onready var join_room_node:Control = $JoinRoom
@onready var matching_node:Control = $Matching

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	join_room_node.visible = true
	matching_node.visible = false


func _on_join_room_success_join() -> void:
	join_room_node.visible = false
	matching_node.visible = true
