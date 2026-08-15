extends Node2D

const HandDirectionSelector = preload("res://script/battle/battle_ui_layer/hand_direction_selector.gd")
const ActionSelector = preload("res://script/battle/UI/action_selector.gd")
const EffectManager = preload("res://script/battle/effect_manager.gd")
const AikoCounter = preload("res://script/battle/UI/aiko_counter.gd")

## じゃんけんの結果を見せてから次に進むまでの待ち時間（秒）
const JANKEN_RESULT_DISPLAY_TIME := 1.5

enum Player{
	HOST,
	JOIN
}

## 選択されたキャラのデータ。setup_charas()で入る
var host_chara_data:CharaData
var join_chara_data:CharaData

var host_hp:int = 0
var host_hp_max:int = 0

var join_hp:int = 0
var join_hp_max:int = 0

## 連続であいこになった回数
var aiko_count:int = 0

var current_janken_result:BattleEnum.JankenResult

@onready var player_chara_node:CharaBase = $CharaManager/PlayerChara
@onready var opponent_chara_node:CharaBase = $CharaManager/OpponentChara

@onready var hand_direction_selector_node:HandDirectionSelector = $SelectorLayer/HandDirectionSelector
@onready var action_selector_node:ActionSelector = $SelectorLayer/ActionSelector
@onready var aiko_counter_node:AikoCounter = $StatusLayer/AikoCountor

@onready var effect_manager_node:EffectManager = $EffectManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameSession.select_mode_completed.connect(_on_select_mode_completed)
	GameSession.select_mode_restarted.connect(_on_select_mode_restarted)
	GameSession.changed_phase.connect(_on_changed_phase)

	setup_charas()

	if multiplayer.is_server():
		start_turn()

## 選択されたキャラのデータを読み込み、HPをそのキャラの最大値で初期化する
func setup_charas() -> void:
	host_chara_data = GameSession.get_chara_data(BattleEnum.Player.HOST)
	join_chara_data = GameSession.get_chara_data(BattleEnum.Player.JOIN)

	if host_chara_data == null or join_chara_data == null:
		push_warning("キャラが決まっていないため、HPを初期化できません")
		return

	host_hp_max = host_chara_data.max_hp
	host_hp = host_hp_max

	join_hp_max = join_chara_data.max_hp
	join_hp = join_hp_max

## ターンを開始する。ホストが呼ぶと両者のフェーズが進む
func start_turn() -> void:
	set_aiko_count(0)
	GameSession.advance_phase(BattleEnum.Phase.SELECT_ACTION)

## recent_hp_data = { Player.Host: "Hostの体力", Player.JOIN:"Joinの体力"}
func play_damage_effect(recent_hp_data:Dictionary[Player,int],target:Player) -> void:
	pass

func handle_janken() -> void:
	var host_hand:BattleEnum.Hand = GameSession.get_value(BattleEnum.SelectMode.HAND,BattleEnum.Player.HOST)
	var join_hand:BattleEnum.Hand = GameSession.get_value(BattleEnum.SelectMode.HAND,BattleEnum.Player.JOIN)
	var result:BattleEnum.JankenResult = BattleJudge.judge_janken(host_hand,join_hand)

	effect_manager_node.show_janken(host_hand,join_hand)

	if result == BattleEnum.JankenResult.DRAW:
		await handle_aiko()
		return
	
	set_aiko_count(0)
	
	current_janken_result = result
	
	await get_tree().create_timer(JANKEN_RESULT_DISPLAY_TIME).timeout
	
	await effect_manager_node.emphasis_janken(result)
	effect_manager_node.hide_janken()
	
	hand_direction_selector_node.start_direction()

## あいこだったときの処理。結果を見せてから、じゃんけんをやり直させる
func handle_aiko() -> void:
	set_aiko_count(aiko_count + 1)

	# やり直しの合図はホストだけが出し、両者が_on_select_mode_restarted()で受け取る
	if not multiplayer.is_server():
		return
	await get_tree().create_timer(JANKEN_RESULT_DISPLAY_TIME).timeout
	GameSession.restart_select_mode(BattleEnum.SelectMode.HAND)
	

## あいこの回数を更新し、表示に反映する
func set_aiko_count(count:int) -> void:
	aiko_count = count
	aiko_counter_node.set_count(aiko_count)

## フェーズが切り替わったときに両者で呼ばれる
func _on_changed_phase(phase: BattleEnum.Phase) -> void:
	match phase:
		BattleEnum.Phase.SELECT_ACTION:
			action_selector_node.visible = true


## 両者の選択が出揃ったときに呼ばれる。values = { BattleEnum.Player : 選んだ値 }
func _on_select_mode_completed(mode: BattleEnum.SelectMode, values: Dictionary) -> void:
	match mode:
		BattleEnum.SelectMode.ACTION:
			if values[BattleEnum.Player.HOST] == BattleEnum.Action.SKILL:
				pass
			if values[BattleEnum.Player.JOIN] == BattleEnum.Action.SKILL:
				pass

			hand_direction_selector_node.start_janken();
		BattleEnum.SelectMode.HAND:
			handle_janken()
		BattleEnum.SelectMode.DIRECTION:
			pass


## 選択がやり直しになったときに両者で呼ばれる
func _on_select_mode_restarted(mode: BattleEnum.SelectMode) -> void:
	match mode:
		BattleEnum.SelectMode.HAND:
			effect_manager_node.hide_janken()
			hand_direction_selector_node.start_janken()
	
## 残ターンが0になったときに呼ばれる処理
func turn_limit_reached() -> void:
	# ゼロ除算を防ぎつつHP割合（0.0 〜 1.0）を計算
	var host_ratio: float = float(host_hp) / float(host_hp_max) if host_hp_max > 0 else 0.0
	var join_ratio: float = float(join_hp) / float(join_hp_max) if join_hp_max > 0 else 0.0

	var winner: BattleEnum.Winner

	if host_ratio > join_ratio:
		winner = BattleEnum.Winner.HOST
	elif join_ratio > host_ratio:
		winner = BattleEnum.Winner.JOIN
	else:
		winner = BattleEnum.Winner.DRAW

	finish_battle(winner)

func finish_battle(winner:BattleEnum.Winner) -> void:
	pass

func _on_action_selector_attack_selected() -> void:
	GameSession.submit(BattleEnum.SelectMode.ACTION, BattleEnum.Action.ATTACK)
	action_selector_node.visible = false


func _on_action_selector_skill_selected() -> void:
	GameSession.submit(BattleEnum.SelectMode.ACTION, BattleEnum.Action.SKILL)
	action_selector_node.visible = false


func _on_hand_direction_selector_direction_selected(direction: BattleEnum.Direction) -> void:
	GameSession.submit(BattleEnum.SelectMode.DIRECTION, direction)


func _on_hand_direction_selector_hands_selected(hand: BattleEnum.Hand) -> void:
	GameSession.submit(BattleEnum.SelectMode.HAND, hand)
