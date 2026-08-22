extends CanvasLayer

const JankenResult = preload("res://script/battle/janken_result/janken_result.gd")
const HoiResult = preload("res://script/battle/hoi_result/hoi_result.gd")
const CutinEffect = preload("res://script/battle/effect_manager/cutin_effect.gd")
const AttackEffect = preload("res://script/battle/attack_effect/attack_effect.gd")
const SkillEffect = preload("res://script/battle/skill_effect/skill_effect.gd")

@onready var janken_result_node:JankenResult = $JankenResult
@onready var hoi_result_node:HoiResult = $HoiResult
@onready var cutin_effect_node:CutinEffect = $CutinEffect
@onready var attack_effect_node:AttackEffect = $AttackEffect
@onready var skill_effect_node:SkillEffect = $SkillEffect

func show_janken(host_hand:BattleEnum.Hand,join_hand:BattleEnum.Hand) ->void:
	if GameSession.is_self(BattleEnum.Player.HOST):
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


func show_hoi(host_direction:Array[BattleEnum.Direction],join_direction:Array[BattleEnum.Direction]) -> void:
	if GameSession.is_self(BattleEnum.Player.HOST):
		hoi_result_node.show_hoi(host_direction,join_direction)
	else:
		hoi_result_node.show_hoi(join_direction,host_direction)

func hide_hoi() -> void:
	hoi_result_node.hide_hoi()

func play_cutin(chara:CharaData) -> void:
	await cutin_effect_node.play_cutin(chara)

func play_attack(attacker:BattleEnum.Player) -> void:
	await attack_effect_node.play_attack(attacker == GameSession.get_self_player())

func play_guard(attacker:BattleEnum.Player) -> void:
	await attack_effect_node.play_guard(attacker == GameSession.get_self_player())

func play_skill_effect(user:BattleEnum.Player,chara:CharaData) -> void:
	var user_is_player:bool = (user == GameSession.get_self_player())
	await skill_effect_node.play_skill_effect(user_is_player,chara)
