extends Node2D

const HandDirectionSelector = preload("res://script/battle/battle_ui_layer/hand_direction_selector.gd")
const ActionSelector = preload("res://script/battle/UI/action_selector.gd")
const EffectManager = preload("res://script/battle/effect_manager.gd")
const AikoCounter = preload("res://script/battle/UI/aiko_counter.gd")
const StatusDisplayManager = preload("res://script/battle/UI/status_display/status_display_manager.gd")
const CharaManager = preload("res://script/battle/chara_manager/chara_manager.gd")

## じゃんけんの結果を見せてから次に進むまでの待ち時間（秒）
const JANKEN_RESULT_DISPLAY_TIME:float = 1.5

const HOI_RESULT_DISPLAY_TIME:float = 1.5

const AFTER_DAMAGE_EFFECT_TIME:float = 1.0


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

@onready var chara_manager_node:CharaManager = $CharaManager

@onready var hand_direction_selector_node:HandDirectionSelector = $SelectorLayer/HandDirectionSelector
@onready var action_selector_node:ActionSelector = $SelectorLayer/ActionSelector
@onready var aiko_counter_node:AikoCounter = $StatusLayer/AikoCountor

@onready var effect_manager_node:EffectManager = $EffectManager

@onready var status_display_manager_node:StatusDisplayManager = $StatusLayer/StatusDisplayManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameSession.select_mode_completed.connect(_on_select_mode_completed)
	GameSession.select_mode_restarted.connect(_on_select_mode_restarted)
	GameSession.changed_phase.connect(_on_changed_phase)
	GameSession.damage_applied.connect(_on_damage_applied)

	setup_charas()
	setup_usernames()

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
	
	status_display_manager_node.set_chara(host_chara_data,join_chara_data)
	chara_manager_node.set_chara(host_chara_data,join_chara_data)

## 両者のユーザー名を表示に反映する
func setup_usernames() -> void:
	status_display_manager_node.set_username(
		GameSession.get_username(BattleEnum.Player.HOST),
		GameSession.get_username(BattleEnum.Player.JOIN)
	)

## ターンを開始する。ホストが呼ぶと両者のフェーズが進む
func start_turn() -> void:
	set_aiko_count(0)
	GameSession.advance_phase(BattleEnum.Phase.SELECT_ACTION)

## ターンの終わりに関する処理
func end_turn() -> void:
	if not multiplayer.is_server():
		return
	
	if host_hp <= 0 and join_hp <= 0:
		finish_battle(BattleEnum.Winner.DRAW)
	elif host_hp <= 0:
		finish_battle(BattleEnum.Winner.JOIN)
	elif join_hp <= 0:
		finish_battle(BattleEnum.Winner.HOST)
	else:
		start_turn()

## ダメージの演出
func play_damage_effect(damage:int,target:BattleEnum.Player) -> void:
	
	status_display_manager_node.set_hp(host_hp,join_hp)
	status_display_manager_node.play_damage(target)
	chara_manager_node.play_damage(target)
	
	await get_tree().create_timer(AFTER_DAMAGE_EFFECT_TIME).timeout
	
	end_turn()


## じゃんけんに関する関数群
#region

## じゃんけんに関する処理。
## 両者、手を選んだ後に、それらを開示し、結果を表示する。
func handle_janken() -> void:
	var host_hand:BattleEnum.Hand = GameSession.get_hand(BattleEnum.Player.HOST)
	var join_hand:BattleEnum.Hand = GameSession.get_hand(BattleEnum.Player.JOIN)
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

#endregion

## 両者が指す方向を選んだあとに実行される。
## 方向を開示して、結果を表示する
func handle_hoi() -> void:
	var host_direction:BattleEnum.Direction = GameSession.get_direction(BattleEnum.Player.HOST)
	var join_direction:BattleEnum.Direction = GameSession.get_direction(BattleEnum.Player.JOIN)

	## じゃんけん勝者が攻撃側になる
	var attacker:BattleEnum.Player
	var defender:BattleEnum.Player

	var pointed:BattleEnum.Direction
	var faced:BattleEnum.Direction

	match current_janken_result:
		BattleEnum.JankenResult.HOST_WIN:
			attacker = BattleEnum.Player.HOST
			defender = BattleEnum.Player.JOIN
			pointed = host_direction;
			faced = join_direction
		BattleEnum.JankenResult.JOIN_WIN:
			attacker = BattleEnum.Player.JOIN
			defender = BattleEnum.Player.HOST
			pointed = join_direction;
			faced = host_direction
		BattleEnum.JankenResult.DRAW:
			push_error("誤って引き分けの状態であっち向いてホイに移行しています")
			return

	## ガードに成功したか
	var is_guard_success:bool = BattleJudge.judge_hoi(pointed,faced)
	
	effect_manager_node.show_hoi(host_direction,join_direction)

	await get_tree().create_timer(HOI_RESULT_DISPLAY_TIME).timeout

	effect_manager_node.hide_hoi()

	if is_guard_success:
		guard()
	else:
		resolve_attack(attacker,defender)


func guard() -> void:
	pass

## じゃんけん勝者の攻撃を確定させる。
## 両者でHPがズレないよう、計算はホストだけが行い、確定後のHPをGameSessionが両者に配る
func resolve_attack(attacker:BattleEnum.Player,defender:BattleEnum.Player) -> void:
	if not multiplayer.is_server():
		return

	var attacker_data:CharaData = host_chara_data if attacker == BattleEnum.Player.HOST else join_chara_data
	if attacker_data == null:
		push_warning("攻撃側のキャラが不明なため、ダメージを計算できません")
		return

	var damage:int = BattleJudge.calc_damage(attacker_data)

	var recent_hp:Dictionary[BattleEnum.Player,int] = {
		BattleEnum.Player.HOST: host_hp,
		BattleEnum.Player.JOIN: join_hp,
	}
	recent_hp[defender] = maxi(0, recent_hp[defender] - damage)

	GameSession.apply_damage(defender, recent_hp, damage)

func _on_damage_applied(defender:BattleEnum.Player, hp:Dictionary[BattleEnum.Player,int], damage:int) -> void:
	host_hp = hp[BattleEnum.Player.HOST]
	join_hp = hp[BattleEnum.Player.JOIN]
	
	play_damage_effect(damage,defender)


## 両者の選択が出揃ったときに呼ばれる。values = { BattleEnum.Player : 選んだ値 }
func _on_select_mode_completed(mode: BattleEnum.SelectMode, values: Dictionary) -> void:
	match mode:
		BattleEnum.SelectMode.ACTION:
			if GameSession.get_action(BattleEnum.Player.HOST) == BattleEnum.Action.SKILL:
				pass
			if GameSession.get_action(BattleEnum.Player.JOIN) == BattleEnum.Action.SKILL:
				pass

			hand_direction_selector_node.start_janken();
		BattleEnum.SelectMode.HAND:
			handle_janken()
		BattleEnum.SelectMode.DIRECTION:
			handle_hoi()


## 選択がやり直しになったときに両者で呼ばれる
func _on_select_mode_restarted(mode: BattleEnum.SelectMode) -> void:
	match mode:
		BattleEnum.SelectMode.HAND:
			effect_manager_node.hide_janken()
			hand_direction_selector_node.start_janken()

## 残ターンが0になったときに呼ばれる処理
func turn_limit_reached() -> void:
	pass

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
