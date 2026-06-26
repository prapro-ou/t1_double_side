extends Control

const Matching = preload("res://script/lobby/host/matching_host.gd")

@onready var build_room_node:Control = $BuildRoom
@onready var matching_node:Matching = $Matching

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	build_room_node.visible = true
	matching_node.visible = false


func _on_build_room_success_build(roomname:String) -> void:
	build_room_node.visible = false
	matching_node.visible = true

	matching_node.setup(roomname)
