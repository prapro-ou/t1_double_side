extends Node2D

const JankenResult = preload("res://script/battle/janken_result/janken_result.gd")

@onready var janken_result_node:JankenResult = $JankenResult

func show_janken(host_hand:BattleEnum.Hand,join_hand:BattleEnum.Hand) ->void:
	if multiplayer.is_server():
		janken_result_node.show_hand(host_hand,join_hand)
	else:
		janken_result_node.show_hand(join_hand,host_hand)

func emphasis_janken(result:BattleEnum.JankenResult) -> void:
	if multiplayer.is_server():
		if result == BattleEnum.JankenResult.HOST_WIN:
			await janken_result_node.emphasis_janken(true)
		else:
			await janken_result_node.emphasis_janken(false)
	else:
		if result == BattleEnum.JankenResult.JOIN_WIN:
			await janken_result_node.emphasis_janken(true)
		else:
			await janken_result_node.emphasis_janken(false)

func hide_janken() -> void:
	janken_result_node.hide_hand()
