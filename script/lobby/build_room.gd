extends Control

signal success_build()

@onready var name_edit_node:LineEdit = $NameEdit
@onready var room_edit_node:LineEdit = $RoomEdit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var username:String = name_edit_node.text
	var roomname:String = room_edit_node.text
	
	if username.length() <= 0:
		pass
	
	if roomname.length() <= 0:
		pass
	
	
