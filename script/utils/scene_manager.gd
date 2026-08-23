extends Node

const scene_dictionary:Dictionary[String,PackedScene] = {
	"title":preload("res://scene/title.tscn"),
	"how_to_play":preload("res://scene/how_to_play.tscn"),
	"credit":preload("res://scene/credit.tscn"),
	"lobby":preload("res://scene/lobby.tscn"),
	"chara_select":preload("res://scene/chara_select.tscn"),
	"webrtc_test":preload("res://scene/webrtc_test.tscn"),
	"battle":preload("res://scene/battle.tscn"),
	"result":preload("res://scene/result.tscn"),
	"network_end":preload("res://components/network_end.tscn"),
	"network_error":preload("res://components/network_error.tscn")
}

func _ready() -> void:
	# 通信が切断されたら、どのsceneにいても通信エラー画面へ移動する
	NetworkManager.connection_lost.connect(network_error)

func change_scene(key:String):
	get_tree().change_scene_to_packed(scene_dictionary[key])

func network_error() -> void:
	change_scene("network_error")
