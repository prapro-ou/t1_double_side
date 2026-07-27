extends Node

const scene_dictionary:Dictionary[String,PackedScene] = {
	"title":preload("res://scene/title.tscn"),
	"lobby":preload("res://scene/lobby.tscn"),
	"chara_select":preload("res://scene/chara_select.tscn"),
	"webrtc_test":preload("res://scene/webrtc_test.tscn"),
	"battle":preload("res://scene/battle.tscn"),
	"result":preload("res://scene/result.tscn")
}

func change_scene(key:String):
	get_tree().change_scene_to_packed(scene_dictionary[key])
