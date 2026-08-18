extends Node2D

const HoiViewer = preload("res://script/battle/hoi_result/hoi_viewer.gd")

@onready var player_hoi_node:HoiViewer = $PlayerHoi
@onready var opponent_hoi_node:HoiViewer = $OpponentHoi

func show_hoi(player_hoi:BattleEnum.Direction,opponent_hoi:BattleEnum.Direction) -> void:
	player_hoi_node.set_direction(player_hoi)
	opponent_hoi_node.set_direction(opponent_hoi)
	visible = true;


func hide_hoi() -> void:
	visible = false
