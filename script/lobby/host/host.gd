extends Control

@onready var build_room_node:Control = $BuildRoom
@onready var matching_node:Control = $Matching

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	build_room_node.visible = true
	matching_node.visible = false
	


func _on_build_room_success_build() -> void:
	build_room_node.visible = false
	matching_node.visible = true
