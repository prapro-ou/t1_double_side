extends Node

const scene_dictionary:Dictionary[String,PackedScene] = {
	"title":preload("res://scene/title.tscn"),
	"lobby":preload("res://scene/lobby.tscn"),
	"webrtc_test":preload("res://scene/webrtc_test.tscn")
}

func change_scene(key:String):
	get_tree().change_scene_to_packed(scene_dictionary[key])
