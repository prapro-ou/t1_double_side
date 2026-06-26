extends Control

signal success_build(roomname:String)

@onready var name_edit_node:LineEdit = $NameEdit
@onready var room_edit_node:LineEdit = $RoomEdit
@onready var button_node:Button = $Button

var _roomname:String = ""

func signal_disconnect() -> void:
	if NetworkManager.room_created.is_connected(_on_room_created):
		NetworkManager.room_created.disconnect(_on_room_created)
	if NetworkManager.signaling_error.is_connected(_on_signaling_error):
		NetworkManager.signaling_error.disconnect(_on_signaling_error)

func _on_button_pressed() -> void:
	var username:String = name_edit_node.text
	var roomname:String = room_edit_node.text

	if username.length() > 0 and roomname.length() > 0:
		_roomname = roomname
		NetworkManager.host_game(username,roomname,2)
		if not NetworkManager.room_created.is_connected(_on_room_created):
			NetworkManager.room_created.connect(_on_room_created)
		if not NetworkManager.signaling_error.is_connected(_on_signaling_error):
			NetworkManager.signaling_error.connect(_on_signaling_error)

func _on_room_created() -> void:
	success_build.emit(_roomname)
	signal_disconnect()

func _on_signaling_error(message:String) -> void:
	print(message)
	signal_disconnect()


func _on_back_button_pressed() -> void:
	signal_disconnect()
	NetworkManager.leave()
	SceneManager.change_scene("title")
