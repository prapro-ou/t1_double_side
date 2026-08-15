extends Node2D

const JankenResult = preload("res://script/battle/janken_result/janken_result.gd")

@onready var janken_result_node:JankenResult = $JankenResult

func show_janken(host_hand:BattleEnum.Hand,join_hand:BattleEnum.Hand) ->void:
	if GameSession.get_self_player() == BattleEnum.Player.HOST:
		janken_result_node.show_hand(host_hand,join_hand)
	else:
		janken_result_node.show_hand(join_hand,host_hand)

func emphasis_janken(result:BattleEnum.JankenResult) -> void:
	if BattleJudge.is_janken_winner(result,GameSession.get_self_player()):
		await janken_result_node.emphasis_janken(true)
	else:
		await janken_result_node.emphasis_janken(false)


func hide_janken() -> void:
	janken_result_node.hide_hand()
