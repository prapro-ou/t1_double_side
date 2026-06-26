extends Control

signal success_join(host_name:String,password:String)

@onready var name_edit_node:LineEdit = $NameEdit
@onready var room_edit_node:LineEdit = $RoomEdit
@onready var button_node:Button = $Button

var _roomname:String = ""

func signal_disconnect() -> void:
	if NetworkManager.joined_room.is_connected(_on_joined_room):
		NetworkManager.joined_room.disconnect(_on_joined_room)
	if NetworkManager.signaling_error.is_connected(_on_signaling_error):
		NetworkManager.signaling_error.disconnect(_on_signaling_error)

func _on_button_pressed() -> void:
	var username:String = name_edit_node.text
	var roomname:String = room_edit_node.text

	if username.length() > 0 and roomname.length() > 0:
		_roomname = roomname
		NetworkManager.join_game(username,roomname)
		if not NetworkManager.joined_room.is_connected(_on_joined_room):
			NetworkManager.joined_room.connect(_on_joined_room)
		if not NetworkManager.signaling_error.is_connected(_on_signaling_error):
			NetworkManager.signaling_error.connect(_on_signaling_error)

func _on_joined_room(hostname:String) -> void:
	success_join.emit(hostname,_roomname)
	signal_disconnect()

func _on_signaling_error(message:String) -> void:
	print(message)
	signal_disconnect()


func _on_back_button_pressed() -> void:
	signal_disconnect()
	NetworkManager.leave()
	SceneManager.change_scene("title")
