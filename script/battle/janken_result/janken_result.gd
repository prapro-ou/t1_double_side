extends Node2D

const HandViewer = preload("res://script/battle/janken_result/hand_viewer.gd")

@onready var player_hand_node:HandViewer = $PlayerHand
@onready var opponent_hand_node:HandViewer = $OpponentHand

func show_hand(player_hand:BattleEnum.Hand,opponent_hand:BattleEnum.Hand) -> void:
	player_hand_node.set_hand(player_hand)
	opponent_hand_node.set_hand(opponent_hand)
	visible = true;
