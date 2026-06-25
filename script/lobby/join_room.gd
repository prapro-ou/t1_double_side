extends Control

signal success_join()

@onready var name_edit_node:LineEdit = $NameEdit
@onready var room_edit_node:LineEdit = $RoomEdit
@onready var button_node:Button = $Button

func signal_disconnect() -> void:
	NetworkManager.joined_room.disconnect(_on_joined_room)
	NetworkManager.signaling_error.disconnect(_on_signaling_error)

func _on_button_pressed() -> void:
	var username:String = name_edit_node.text
	var roomname:String = room_edit_node.text
	
	if username.length() > 0 and roomname.length() > 0:
		NetworkManager.join_game(username,roomname)
		NetworkManager.joined_room.connect(_on_joined_room)
		NetworkManager.signaling_error.connect(_on_signaling_error)

func _on_joined_room():
	success_join.emit();
	signal_disconnect();

func _on_signaling_error():
	signal_disconnect();
