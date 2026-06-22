extends Node

const scene_dictionary:Dictionary[String,PackedScene] = {
	"matching_select":preload("res://scene/matching_select.tscn"),
	"lobby":preload("res://scene/lobby.tscn")
}

func change_scene(key:String):
	get_tree().change_scene_to_packed(scene_dictionary[key])
