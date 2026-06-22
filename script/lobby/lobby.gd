extends Node2D

@onready var host_node:Control = $CanvasLayer/Host
@onready var join_node:Control = $CanvasLayer/Join


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(NetworkManager.is_host):
		host_node.visible = true
	else:
		join_node.visible = true
	
	
	
