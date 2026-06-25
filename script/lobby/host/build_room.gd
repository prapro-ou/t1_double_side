extends Control

signal success_build()

@onready var name_edit_node:LineEdit = $NameEdit
@onready var room_edit_node:LineEdit = $RoomEdit
@onready var button_node:Button = $Button

func signal_disconnect() -> void:
	NetworkManager.room_created.disconnect(_on_room_created)
	NetworkManager.signaling_error.disconnect(_on_signaling_error)

func _on_button_pressed() -> void:
	var username:String = name_edit_node.text
	var roomname:String = room_edit_node.text
	
	if username.length() > 0 and roomname.length() > 0:
		NetworkManager.host_game(username,roomname,2)
		NetworkManager.room_created.connect(_on_room_created)
		NetworkManager.signaling_error.connect(_on_signaling_error)

func _on_room_created() -> void:
	success_build.emit()
	signal_disconnect()

func _on_signaling_error() -> void:
	signal_disconnect()
