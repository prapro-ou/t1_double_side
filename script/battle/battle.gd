extends Node2D

const HandDirectionSelector = preload("res://script/battle/battle_ui_layer/hand_direction_selector.gd")
const ActionSelector = preload("res://script/battle/UI/action_selector.gd")
const EffectManager = preload("res://script/battle/effect_manager/effect_manager.gd")
const AikoCounter = preload("res://script/battle/UI/aiko_counter.gd")
const StatusDisplayManager = preload("res://script/battle/UI/status_display/status_display_manager.gd")
const CharaManager = preload("res://script/battle/chara_manager/chara_manager.gd")


## ターン終了時に両者に与えられるMP
@export var turn_end_mp_up:int
## ガードに成功したときに貰えるMP
@export var guard_mp_up:int
## 決め台詞成功時に貰えるMP
@export var catchphrase_mp_up:int

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

## MPは0から始まり、ガードや決め台詞で溜まる
var host_mp:int = 0
var host_mp_max:int = 0

var join_mp:int = 0
var join_mp_max:int = 0

## 連続であいこになった回数
var aiko_count:int = 0

var current_janken_result:BattleEnum.JankenResult

@onready var battle_status_node:BattleStatus = $BattleStatus

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
	GameSession.mp_changed.connect(_on_mp_changed)

	setup_charas()
	setup_usernames()

	if multiplayer.is_server():
		start_turn()

##ゲームスタート時の互いの設定について
#region

## 選択されたキャラのデータを読み込み、HP/MPをそのキャラの最大値で初期化する
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

	host_mp_max = host_chara_data.max_mp
	host_mp = 0

	join_mp_max = join_chara_data.max_mp
	join_mp = 0

	status_display_manager_node.set_chara(host_chara_data,join_chara_data)
	chara_manager_node.set_chara(host_chara_data,join_chara_data)
	status_display_manager_node.set_mp(host_mp,join_mp)
	
	if GameSession.get_self_player() == BattleEnum.Player.HOST:
		action_selector_node.set_chara(host_chara_data)
	else:
		action_selector_node.set_chara(join_chara_data)

## 両者のユーザー名を表示に反映する
func setup_usernames() -> void:
	status_display_manager_node.set_username(
		GameSession.get_username(BattleEnum.Player.HOST),
		GameSession.get_username(BattleEnum.Player.JOIN)
	)

#endregion

func set_select_button_disable() -> void:
	var skill_disable:bool
	var catchphrase_disable:bool
	
	if GameSession.get_self_player() == BattleEnum.Player.HOST:
		skill_disable = host_mp < host_mp_max
		catchphrase_disable = battle_status_node.catchphrase_used[BattleEnum.Player.HOST]
	else:
		skill_disable = join_mp < join_mp_max
		catchphrase_disable = battle_status_node.catchphrase_used[BattleEnum.Player.JOIN]
	
	action_selector_node.set_button_disable(skill_disable,catchphrase_disable)

## フェーズが切り替わったときに両者で呼ばれる
func _on_changed_phase(phase: BattleEnum.Phase) -> void:
	match phase:
		BattleEnum.Phase.SELECT_ACTION:
			action_selector_node.visible = true
			set_select_button_disable()

func refresh_step() -> void:
	battle_status_node.clear_turn_flag()
	end_turn()

## ターンを開始する。ホストが呼ぶと両者のフェーズが進む
func start_turn() -> void:
	set_aiko_count(0)
	GameSession.advance_phase(BattleEnum.Phase.SELECT_ACTION)
	


## ターンの終わりに関する処理
func end_turn() -> void:	
	if not multiplayer.is_server():
		return
	
	change_mp({
		BattleEnum.Player.HOST:turn_end_mp_up,
		BattleEnum.Player.JOIN:turn_end_mp_up
	})
	
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
	
	refresh_step()


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
	
	check_catchphrase(result)

	# ガードの成否が確定しているときは方向選択を飛ばし、そのまま攻撃を通す
	if is_skip_select_direction():
		resolve_attack(get_attacker(),get_defender())
	else:
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

#endregion

## あっち向いてホイについて
#region

## じゃんけん勝者（攻撃側）を返す。あいこのまま呼んではいけない
func get_attacker() -> BattleEnum.Player:
	return BattleEnum.Player.HOST if current_janken_result == BattleEnum.JankenResult.HOST_WIN else BattleEnum.Player.JOIN

## じゃんけん敗者（防御側）を返す。あいこのまま呼んではいけない
func get_defender() -> BattleEnum.Player:
	return BattleEnum.Player.JOIN if current_janken_result == BattleEnum.JankenResult.HOST_WIN else BattleEnum.Player.HOST

## あっち向いてホイを飛ばすかどうかを返す。
## ガードの成否がすでに確定しているなら、方向を選ばせても結果が変わらないため飛ばす
func is_skip_select_direction() -> bool:
	# 攻撃側が相手のガードを無視する
	if battle_status_node.get_turn_flag(get_attacker(),BattleEnum.TurnFlag.FIRE_IGNORE_GUARD):
		return true

	# 防御側がそもそもガードできない
	if battle_status_node.get_turn_flag(get_defender(),BattleEnum.TurnFlag.FIRE_DISABLE_GUARD):
		return true

	return false

## 両者が指す方向を選んだあとに実行される。
## 方向を開示して、結果を表示する
func handle_hoi() -> void:
	var host_direction:BattleEnum.Direction = GameSession.get_direction(BattleEnum.Player.HOST)
	var join_direction:BattleEnum.Direction = GameSession.get_direction(BattleEnum.Player.JOIN)

	## じゃんけん勝者が攻撃側になる
	var attacker:BattleEnum.Player = get_attacker()
	var defender:BattleEnum.Player = get_defender()

	var pointed:BattleEnum.Direction
	var faced:BattleEnum.Direction

	match current_janken_result:
		BattleEnum.JankenResult.HOST_WIN:
			pointed = host_direction;
			faced = join_direction
		BattleEnum.JankenResult.JOIN_WIN:
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
		guard(defender)
	else:
		resolve_attack(attacker,defender)


#endregion

## 攻撃周りの処理
#region

func guard(defender:BattleEnum.Player) -> void:
	change_mp({
		defender:guard_mp_up
	})
	
	refresh_step()

## じゃんけん勝者の攻撃を確定させる。
## 両者でHPがズレないよう、計算はホストだけが行い、確定後のHPをGameSessionが両者に配る
func resolve_attack(attacker:BattleEnum.Player,defender:BattleEnum.Player) -> void:
	if not multiplayer.is_server():
		return

	var attacker_data:CharaData = host_chara_data if attacker == BattleEnum.Player.HOST else join_chara_data
	if attacker_data == null:
		push_warning("攻撃側のキャラが不明なため、ダメージを計算できません")
		return

	var damage:int = attacker_data.attack

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

#endregion

## MPの増減に関する関数群
#region

## MPを増減させる。MPを動かすときは必ずこの関数を通すこと。
## changes = { BattleEnum.Player : 増減値 }。マイナスを渡せば消費になる。
## 両者でMPがズレないよう、計算はホストだけが行い、確定後のMPをGameSessionが両者に配る
func change_mp(changes:Dictionary[BattleEnum.Player,int]) -> void:
	if not multiplayer.is_server():
		return

	var recent_mp:Dictionary[BattleEnum.Player,int] = {
		BattleEnum.Player.HOST: host_mp,
		BattleEnum.Player.JOIN: join_mp,
	}
	for player:BattleEnum.Player in changes:
		recent_mp[player] = _mp_after(player, changes[player])
	
	GameSession.apply_mp(recent_mp)

## 指定プレイヤーの現在MPを返す
func get_mp(player:BattleEnum.Player) -> int:
	return host_mp if player == BattleEnum.Player.HOST else join_mp

## 指定プレイヤーの最大MPを返す
func get_mp_max(player:BattleEnum.Player) -> int:
	return host_mp_max if player == BattleEnum.Player.HOST else join_mp_max

## 指定プレイヤーのMPをamountだけ動かした結果を、0〜最大値に収めて返す。
## 上限・下限のチェックはここだけで行う
func _mp_after(player:BattleEnum.Player, amount:int) -> int:
	return clampi(get_mp(player) + amount, 0, get_mp_max(player))

## MPが確定したときに両者で呼ばれる
func _on_mp_changed(mp:Dictionary[BattleEnum.Player,int]) -> void:
	host_mp = mp[BattleEnum.Player.HOST]
	join_mp = mp[BattleEnum.Player.JOIN]
	
	status_display_manager_node.set_mp(host_mp,join_mp)

#endregion


## スキルに関する処理
func handle_skill(user:BattleEnum.Player, chara:CharaData) -> void:
	pass

## 決め台詞に関する処理
func handle_catchphrase(user:BattleEnum.Player, chara:CharaData) -> void:
	battle_status_node.catchphrase_used[user] = true;
	battle_status_node.add_turn_flag(user,BattleEnum.TurnFlag.CATCHPHRASE)
	await effect_manager_node.play_cutin(chara)
	

func resolve_catchphrase(target:BattleEnum.Player, is_success:bool) -> void:
	var charas:Dictionary[BattleEnum.Player, CharaData] = {
		BattleEnum.Player.HOST:host_chara_data,
		BattleEnum.Player.JOIN:join_chara_data
	}
	match charas[target].id:
		&"fire_man":
			if is_success:
				battle_status_node.add_turn_flag(target,BattleEnum.TurnFlag.FIRE_IGNORE_GUARD)
			else:
				battle_status_node.add_turn_flag(target,BattleEnum.TurnFlag.FIRE_DISABLE_GUARD)
		&"guard_man":
			if is_success:
				battle_status_node.add_permanence_flag(target,BattleEnum.PermanenceFlag.GUARD_CP_ARMOR)
			else:
				battle_status_node.add_permanence_flag(target,BattleEnum.PermanenceFlag.GUARD_CP_WEEK)
		&"logic_woman":
			var opponent:BattleEnum.Player = (
				BattleEnum.Player.JOIN if target == BattleEnum.Player.HOST
				else BattleEnum.Player.HOST
			)
			if is_success:
				# 相手のMPを全て奪う
				var drain:int = get_mp(opponent)
				change_mp({target:drain, opponent:-drain})
			else:
				# 逆に相手のMPを満タンにする
				change_mp({opponent:get_mp_max(opponent)})

func check_catchphrase(result:BattleEnum.JankenResult) -> void:
	for target:BattleEnum.Player in [BattleEnum.Player.HOST,BattleEnum.Player.JOIN]:
		if battle_status_node.get_turn_flag(target,BattleEnum.TurnFlag.CATCHPHRASE):
			resolve_catchphrase(target,BattleJudge.is_janken_winner(result,target))
		

## 両者の選択が出揃ったときに呼ばれる。values = { BattleEnum.Player : 選んだ値 }
func _on_select_mode_completed(mode: BattleEnum.SelectMode, values: Dictionary) -> void:
	match mode:
		BattleEnum.SelectMode.ACTION:
			if GameSession.get_action(BattleEnum.Player.HOST) == BattleEnum.Action.SKILL:
				pass
			if GameSession.get_action(BattleEnum.Player.JOIN) == BattleEnum.Action.SKILL:
				pass
			
			if GameSession.get_action(BattleEnum.Player.HOST) == BattleEnum.Action.CATCHPHRASE:
				await handle_catchphrase(BattleEnum.Player.HOST,host_chara_data)
			if GameSession.get_action(BattleEnum.Player.JOIN) == BattleEnum.Action.CATCHPHRASE:
				await handle_catchphrase(BattleEnum.Player.JOIN,join_chara_data)

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

func _on_action_selector_catchphrase_selected() -> void:
	GameSession.submit(BattleEnum.SelectMode.ACTION, BattleEnum.Action.CATCHPHRASE)
	action_selector_node.visible = false

func _on_hand_direction_selector_direction_selected(direction: BattleEnum.Direction) -> void:
	GameSession.submit(BattleEnum.SelectMode.DIRECTION, direction)


func _on_hand_direction_selector_hands_selected(hand: BattleEnum.Hand) -> void:
	GameSession.submit(BattleEnum.SelectMode.HAND, hand)
