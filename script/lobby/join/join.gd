extends Control

const Matching = preload("res://script/lobby/join/matching_join.gd")

@onready var join_room_node:Control = $JoinRoom
@onready var matching_node:Matching = $Matching

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	join_room_node.visible = true
	matching_node.visible = false


func _on_join_room_success_join(hostname:String,password:String) -> void:
	join_room_node.visible = false
	matching_node.visible = true

	matching_node.setup(hostname,password)
