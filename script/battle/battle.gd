extends Node2D

const HandDirectionSelector = preload("res://script/battle/battle_ui_layer/hand_direction_selector.gd")
const ActionSelector = preload("res://script/battle/UI/action_selector.gd")
const EffectManager = preload("res://script/battle/effect_manager/effect_manager.gd")
const LeftTurnTimer = preload("res://script/battle/UI/left_turn_timer.gd")
const AikoCounter = preload("res://script/battle/UI/aiko_counter.gd")
const StatusDisplayManager = preload("res://script/battle/UI/status_display/status_display_manager.gd")
const CharaManager = preload("res://script/battle/chara_manager/chara_manager.gd")

## プレイヤー1人分のキャラ・HP・MPをまとめて持つ
class PlayerStatus:
	var chara:CharaData
	var hp:int
	var hp_max:int
	var mp:int
	var mp_max:int

	## キャラのデータからHP/MPを初期化する。HPは最大値から、MPは0から始まる。
	func _init(chara_data:CharaData = null) -> void:
		chara = chara_data
		hp_max = chara_data.max_hp if chara_data != null else 0
		hp = hp_max
		mp_max = chara_data.max_mp if chara_data != null else 0
		mp = 0


@export var is_debug_mode:bool = false

## 試合の長さ
@export var turn_limit:int = 20

@export var init_mp:int = 30

## ターン終了時に両者に与えられるMP
@export var turn_end_mp_up:int
## ガードに成功したときに貰えるMP
@export var guard_mp_up:int

## あいこによるダメージの増加
@export var aiko_damage_bonus:float

## じゃんけんの結果を見せてから次に進むまでの待ち時間（秒）
const JANKEN_RESULT_DISPLAY_TIME:float = 1.5

const HOI_RESULT_DISPLAY_TIME:float = 1.5

const AFTER_DAMAGE_EFFECT_TIME:float = 1.0

## MPの数字が出てから消えるまでの時間（秒）。chara.tscnのLabelAnimの"mp"の長さに合わせること
const MP_EFFECT_TIME:float = 0.5

## プレイヤーごとのキャラ・HP・MP。setup_charas()で入る。
var player_status_list:Dictionary[BattleEnum.Player, PlayerStatus] = {}

## 連続であいこになった回数
var aiko_count:int = 0

## このターンに残っている攻撃回数
var remaining_attack_count:int = 0

## このターン、防御側が向ける方向の数
var guard_direction_count:int = 1

var current_janken_result:BattleEnum.JankenResult

## 開幕の初期MP配布をまだ受け取っていないか。初回だけは数字の演出を出さない
var is_first_mp_sync:bool = true

@onready var battle_status_node:BattleStatus = $BattleStatus

@onready var chara_manager_node:CharaManager = $CharaManager

@onready var hand_direction_selector_node:HandDirectionSelector = $SelectorLayer/HandDirectionSelector
@onready var action_selector_node:ActionSelector = $SelectorLayer/ActionSelector

@onready var effect_manager_node:EffectManager = $EffectManager

@onready var left_turn_timer_node:LeftTurnTimer = $StatusLayer/LeftTurnTimer
@onready var aiko_counter_node:AikoCounter = $StatusLayer/AikoCountor
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

	
	change_mp({
		BattleEnum.Player.HOST:init_mp,
		BattleEnum.Player.JOIN:init_mp
	})
	
	set_aiko_count(0)
	
	if multiplayer.is_server():
		start_turn()

##ゲームスタート時の互いの設定について
#region

## 選択されたキャラのデータを読み込み、HP/MPをそのキャラの最大値で初期化する
func setup_charas() -> void:
	var host_chara_data:CharaData = GameSession.get_chara_data(BattleEnum.Player.HOST)
	var join_chara_data:CharaData = GameSession.get_chara_data(BattleEnum.Player.JOIN)
	
	player_status_list.clear()
	player_status_list[BattleEnum.Player.HOST] = PlayerStatus.new(host_chara_data)
	player_status_list[BattleEnum.Player.JOIN] = PlayerStatus.new(join_chara_data)
	
	if host_chara_data == null or join_chara_data == null:
		push_warning("キャラが決まっていないため、HPを初期化できません")
	
	status_display_manager_node.set_chara(host_chara_data,join_chara_data)
	chara_manager_node.set_chara(host_chara_data,join_chara_data)
	status_display_manager_node.set_mp(
		player_status_list[BattleEnum.Player.HOST].mp,
		player_status_list[BattleEnum.Player.JOIN].mp
	)

	action_selector_node.set_chara(player_status_list[GameSession.get_self_player()].chara)

## 両者のユーザー名を表示に反映する
func setup_usernames() -> void:
	status_display_manager_node.set_username(
		GameSession.get_username(BattleEnum.Player.HOST),
		GameSession.get_username(BattleEnum.Player.JOIN)
	)

#endregion

func set_select_button_disable() -> void:
	var self_player:BattleEnum.Player = GameSession.get_self_player()
	var self_status:PlayerStatus = player_status_list[self_player]

	var skill_disable:bool = self_status.mp < self_status.mp_max
	var catchphrase_disable:bool = battle_status_node.catchphrase_used[self_player]

	action_selector_node.set_button_disable(skill_disable,catchphrase_disable)

## フェーズが切り替わったときに両者で呼ばれる
func _on_changed_phase(phase: BattleEnum.Phase) -> void:
	match phase:
		BattleEnum.Phase.SELECT_ACTION:
			action_selector_node.visible = true
			set_select_button_disable()

## ターンの進行に関わる部分
#region

## ターンを開始する。ホストが呼ぶと両者のフェーズが進む
## ホスト側でしか呼ばれない点に注意
func start_turn() -> void:
	GameSession.advance_phase(BattleEnum.Phase.SELECT_ACTION)
	

## このターンの攻撃回数を決める。
func setup_attack_count() -> void:
	var attacker:BattleEnum.Player = get_attacker()

	remaining_attack_count = 1

	if battle_status_node.consume_pending_flag(attacker,BattleEnum.PendingFlag.FIRE_SK_DUAL_ATTACK):
		var fd:FireManData = player_status_list[attacker].chara as FireManData
		remaining_attack_count = fd.skill_attack_count

## このターン、防御側が向ける方向の数を決めて返す。
func setup_guard_direction_count() -> void:
	guard_direction_count = 1
	# ガードの成否がすでに確定しているターンは、スキルを空振りさせない
	if is_skip_select_direction():
		return

	var defender:BattleEnum.Player = get_defender()

	if not battle_status_node.consume_pending_flag(defender,BattleEnum.PendingFlag.GUARD_SK_DUAL_BLOCK):
		return

	var gd:GuardManData = player_status_list[defender].chara as GuardManData
	guard_direction_count = gd.skill_guard_direction_count

## 攻撃1回分を始める。
## ガードの成否が確定しているときは方向選択を飛ばし、そのまま攻撃を通す
func start_attack_step() -> void:
	if is_skip_select_direction():
		resolve_attack(get_attacker(),get_defender())
		return

	#ガード側はguard_direction_countに合わせて
	var is_attacker:bool = GameSession.is_self(get_attacker())
	var count:int = 1 if is_attacker else guard_direction_count
	hand_direction_selector_node.start_direction(is_attacker,count)

## 攻撃1回分が終わったときに呼ぶ。
## 攻撃が残っていればあっち向いてホイからやり直し、残っていなければターンを終える
func advance_attack_step() -> void:
	remaining_attack_count -= 1

	if remaining_attack_count <= 0:
		refresh_step()
		return

	if (player_status_list[BattleEnum.Player.HOST].hp <= 0 or player_status_list[BattleEnum.Player.JOIN].hp <= 0):
		refresh_step()
		return

	# やり直しの合図はホストだけが出し、両者が_on_select_mode_restarted()で受け取る
	if not multiplayer.is_server():
		return

	GameSession.restart_select_mode(BattleEnum.SelectMode.DIRECTION)

func refresh_step() -> void:
	turn_limit -= 1;
	left_turn_timer_node.update_turn_display(turn_limit)
	battle_status_node.clear_turn_flag()
	set_aiko_count(0)
	end_turn()

## ターンの終わりに関する処理
func end_turn() -> void:
	if not multiplayer.is_server():
		return
	
	# 以降はホスト側でしか呼ばれない点に注意
	
	change_mp({
		BattleEnum.Player.HOST:turn_end_mp_up,
		BattleEnum.Player.JOIN:turn_end_mp_up
	})

	var host_dead:bool = player_status_list[BattleEnum.Player.HOST].hp <= 0
	var join_dead:bool = player_status_list[BattleEnum.Player.JOIN].hp <= 0

	if host_dead and join_dead:
		GameSession.finish_battle(BattleEnum.Winner.DRAW)
	elif host_dead:
		GameSession.finish_battle(BattleEnum.Winner.JOIN)
	elif join_dead:
		GameSession.finish_battle(BattleEnum.Winner.HOST)
	else:
		
		if turn_limit <= 0:
			turn_limit_reached()
		else:
			start_turn()

#endregion

## ダメージの演出
func play_damage_effect(damage:int,attacker:BattleEnum.Player,target:BattleEnum.Player) -> void:
	status_display_manager_node.set_hp(
		player_status_list[BattleEnum.Player.HOST].hp,
		player_status_list[BattleEnum.Player.JOIN].hp
	)
	
	await effect_manager_node.play_attack(attacker)
	
	status_display_manager_node.play_damage(target)
	chara_manager_node.play_damage(target,damage)
	
	await get_tree().create_timer(AFTER_DAMAGE_EFFECT_TIME).timeout

	advance_attack_step()


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
	
	current_janken_result = result
	
	await get_tree().create_timer(JANKEN_RESULT_DISPLAY_TIME).timeout
	
	await effect_manager_node.emphasis_janken(result)
	effect_manager_node.hide_janken()
	
	check_catchphrase(result)

	setup_attack_count()
	setup_guard_direction_count()
	start_attack_step()

## あいこだったときの処理。結果を見せてから、じゃんけんをやり直させる
func handle_aiko() -> void:
	set_aiko_count(aiko_count + 1)

	# やり直しの合図はホストだけが出し、両者が_on_select_mode_restarted()で受け取る
	if not multiplayer.is_server():
		return

	await get_tree().create_timer(JANKEN_RESULT_DISPLAY_TIME).timeout
	GameSession.restart_select_mode(BattleEnum.SelectMode.HAND)
	

func calc_aiko_rate(count:int) -> float:
	return (1 + aiko_damage_bonus * count)

## あいこの回数を更新し、表示に反映する
func set_aiko_count(count:int) -> void:
	aiko_count = count
	var rate:float = calc_aiko_rate(count)
	
	aiko_counter_node.set_count(aiko_count,rate)

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
	if current_janken_result == BattleEnum.JankenResult.DRAW:
		push_error("誤って引き分けの状態であっち向いてホイに移行しています")
		return

	## じゃんけん勝者が攻撃側になる
	var attacker:BattleEnum.Player = get_attacker()
	var defender:BattleEnum.Player = get_defender()

	## 攻撃側が指差した方向。攻撃側は常に1つしか選べない
	var pointed:BattleEnum.Direction = GameSession.get_direction(attacker)
	## 防御側が向いた方向。デュアルガード中は複数入る
	var faced:Array[BattleEnum.Direction] = GameSession.get_multi_directions(defender)

	## ガードに成功したか
	var is_guard_success:bool = BattleJudge.judge_hoi(pointed,faced)

	effect_manager_node.show_hoi(
		GameSession.get_multi_directions(BattleEnum.Player.HOST),
		GameSession.get_multi_directions(BattleEnum.Player.JOIN)
	)

	await get_tree().create_timer(HOI_RESULT_DISPLAY_TIME).timeout

	effect_manager_node.hide_hoi()

	if is_guard_success:
		guard(attacker,defender)
	else:
		resolve_attack(attacker,defender)


#endregion

## 攻撃周りの処理
#region

## ガード成功時
func guard(attacker:BattleEnum.Player,defender:BattleEnum.Player) -> void:
	
	await effect_manager_node.play_guard(attacker)
	
	change_mp({
		defender:guard_mp_up
	})

	# この直後のターン終了時のMP加算に上書きされないよう、ガードぶんの数字を見せきる。
	# 数字を出すのは両者で走る_on_mp_changed()なので、ホストしか通らないchange_mp()の中では待てない
	await get_tree().create_timer(MP_EFFECT_TIME).timeout

	if battle_status_node.consume_pending_flag(defender,BattleEnum.PendingFlag.LOGIC_SK_COUNTER):
		var ld:LogicWomanData = player_status_list[defender].chara as LogicWomanData
		resolve_counter(defender,attacker,ceili(ld.attack * ld.skill_counter_damage_rate))
		return
	
	advance_attack_step()

## ダメージの計算
func calc_damage(attacker:BattleEnum.Player,defender:BattleEnum.Player,base_damage:int) -> int:
	var damage:int = base_damage
	
	if battle_status_node.get_turn_flag(attacker, BattleEnum.TurnFlag.FIRE_IGNORE_GUARD):
		var fd:FireManData = player_status_list[attacker].chara as FireManData
		damage = ceili(damage * fd.catchphrase_success_damage_rate)
	
	if battle_status_node.get_turn_flag(defender, BattleEnum.TurnFlag.FIRE_DISABLE_GUARD):
		var fd:FireManData = player_status_list[defender].chara as FireManData
		damage = ceili(damage * fd.catchphrase_fail_damage_taken_rate)
	
	if battle_status_node.get_permanence_flag(defender, BattleEnum.PermanenceFlag.GUARD_CP_ARMOR):
		var gd:GuardManData = player_status_list[defender].chara as GuardManData
		damage = floori(damage * gd.catchphrase_success_damage_taken_rate)
	
	if battle_status_node.get_permanence_flag(defender, BattleEnum.PermanenceFlag.GUARD_CP_WEAK):
		var gd:GuardManData = player_status_list[defender].chara as GuardManData
		damage = ceili(damage * gd.catchphrase_fail_damage_taken_rate)
	
	damage = ceili(damage * calc_aiko_rate(aiko_count) )
	
	return damage


## じゃんけん勝者の攻撃を確定させる。
## 両者でHPがズレないよう、計算はホストだけが行い、確定後のHPをGameSessionが両者に配る
func resolve_attack(attacker:BattleEnum.Player,defender:BattleEnum.Player) -> void:
	if not multiplayer.is_server():
		return
		
	var attacker_data:CharaData = player_status_list[attacker].chara
	if attacker_data == null:
		push_warning("攻撃側のキャラが不明なため、ダメージを計算できません")
		return
		
	var recent_hp:Dictionary[BattleEnum.Player,int] = {
		BattleEnum.Player.HOST: player_status_list[BattleEnum.Player.HOST].hp,
		BattleEnum.Player.JOIN: player_status_list[BattleEnum.Player.JOIN].hp,
	}
	
	var damage:int = calc_damage(attacker,defender,attacker_data.attack)
	
	recent_hp[defender] = maxi(0, recent_hp[defender] - damage)

	GameSession.apply_damage(attacker,defender, recent_hp, damage)

## カウンターを確定させる。ガードに成功した側が、じゃんけん勝者に反撃する。
## 反撃の威力は発動元のスキルごとに決めてbase_damageで渡すこと。
## 計算はホストだけが行い、確定後のHPをGameSessionが両者に配る
func resolve_counter(counter_user:BattleEnum.Player,target:BattleEnum.Player,base_damage:int) -> void:
	if not multiplayer.is_server():
		return

	var recent_hp:Dictionary[BattleEnum.Player,int] = {
		BattleEnum.Player.HOST: player_status_list[BattleEnum.Player.HOST].hp,
		BattleEnum.Player.JOIN: player_status_list[BattleEnum.Player.JOIN].hp,
	}

	var damage:int = calc_damage(counter_user,target,base_damage)

	recent_hp[target] = maxi(0, recent_hp[target] - damage)

	GameSession.apply_damage(counter_user,target, recent_hp, damage)

func _on_damage_applied(attacker:BattleEnum.Player,defender:BattleEnum.Player, hp:Dictionary[BattleEnum.Player,int], damage:int) -> void:
	for player:BattleEnum.Player in player_status_list:
		player_status_list[player].hp = hp[player]

	play_damage_effect(damage,attacker,defender)

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
		BattleEnum.Player.HOST: player_status_list[BattleEnum.Player.HOST].mp,
		BattleEnum.Player.JOIN: player_status_list[BattleEnum.Player.JOIN].mp,
	}
	for player:BattleEnum.Player in changes:
		recent_mp[player] = _mp_after(player, changes[player])

	GameSession.apply_mp(recent_mp)

## 指定プレイヤーのMPをamountだけ動かした結果を、0〜最大値に収めて返す。
## 上限・下限のチェックはここだけで行う
func _mp_after(player:BattleEnum.Player, amount:int) -> int:
	var status:PlayerStatus = player_status_list[player]
	return clampi(status.mp + amount, 0, status.mp_max)

## MPが確定したときに両者で呼ばれる。
## 配られるのは確定値なので、反映前の値との差からキャラ上に出す増減量を求める
func _on_mp_changed(mp:Dictionary[BattleEnum.Player,int]) -> void:
	for player:BattleEnum.Player in player_status_list:
		var diff:int = mp[player] - player_status_list[player].mp
		player_status_list[player].mp = mp[player]

		# 開幕の初期MP配布と、スキル使用などによる消費は演出せず、静かに反映するだけにする
		if is_first_mp_sync or diff <= 0:
			continue

		chara_manager_node.play_mp(player,diff)
	
	is_first_mp_sync = false

	status_display_manager_node.set_mp(
		player_status_list[BattleEnum.Player.HOST].mp,
		player_status_list[BattleEnum.Player.JOIN].mp
	)

#endregion


## スキルに関する処理
func handle_skill(user:BattleEnum.Player, chara:CharaData) -> void:
	change_mp({
		user: -chara.max_mp
	})
	
	match player_status_list[user].chara.id:
		&"fire_man":
			battle_status_node.add_pending_flag(user,BattleEnum.PendingFlag.FIRE_SK_DUAL_ATTACK)
		&"guard_man":
			battle_status_node.add_pending_flag(user,BattleEnum.PendingFlag.GUARD_SK_DUAL_BLOCK)
		&"logic_woman":
			battle_status_node.add_pending_flag(user,BattleEnum.PendingFlag.LOGIC_SK_COUNTER)


## 決め台詞に関する処理
func handle_catchphrase(user:BattleEnum.Player, chara:CharaData) -> void:
	battle_status_node.catchphrase_used[user] = true;
	battle_status_node.add_turn_flag(user,BattleEnum.TurnFlag.CATCHPHRASE)
	await effect_manager_node.play_cutin(chara)
	

func resolve_catchphrase(target:BattleEnum.Player, is_success:bool) -> void:
	match player_status_list[target].chara.id:
		&"fire_man":
			if is_success:
				battle_status_node.add_turn_flag(target,BattleEnum.TurnFlag.FIRE_IGNORE_GUARD)
			else:
				battle_status_node.add_turn_flag(target,BattleEnum.TurnFlag.FIRE_DISABLE_GUARD)
		&"guard_man":
			if is_success:
				battle_status_node.add_permanence_flag(target,BattleEnum.PermanenceFlag.GUARD_CP_ARMOR)
			else:
				battle_status_node.add_permanence_flag(target,BattleEnum.PermanenceFlag.GUARD_CP_WEAK)
		&"logic_woman":
			var data:LogicWomanData = player_status_list[target].chara as LogicWomanData
			var opponent:BattleEnum.Player = GameSession.get_other_player(target)
			if is_success:
				# 相手のMPを奪う
				var drain:int = int(player_status_list[opponent].mp * data.catchphrase_success_mp_drain_rate)
				change_mp({target:drain, opponent:-drain})
			else:
				# 逆に相手のMPを増やす
				change_mp({opponent:int(player_status_list[opponent].mp_max * data.catchphrase_fail_mp_up_rate)})

func check_catchphrase(result:BattleEnum.JankenResult) -> void:
	for target:BattleEnum.Player in [BattleEnum.Player.HOST,BattleEnum.Player.JOIN]:
		if battle_status_node.get_turn_flag(target,BattleEnum.TurnFlag.CATCHPHRASE):
			resolve_catchphrase(target,BattleJudge.is_janken_winner(result,target))
		

## 両者の選択が出揃ったときに呼ばれる。values = { BattleEnum.Player : 選んだ値 }
func _on_select_mode_completed(mode: BattleEnum.SelectMode, values: Dictionary) -> void:
	match mode:
		BattleEnum.SelectMode.ACTION:
			for player:BattleEnum.Player in [BattleEnum.Player.HOST,BattleEnum.Player.JOIN]:
				if GameSession.get_action(player) == BattleEnum.Action.SKILL:
					await handle_skill(player,player_status_list[player].chara)
			
			for player:BattleEnum.Player in [BattleEnum.Player.HOST,BattleEnum.Player.JOIN]:
				if GameSession.get_action(player) == BattleEnum.Action.CATCHPHRASE:
					await handle_catchphrase(player,player_status_list[player].chara)
			
			hand_direction_selector_node.start_janken();
		BattleEnum.SelectMode.HAND:
			# 相手も選び終わったので「待機中」の表示を消す
			hand_direction_selector_node.hide_label()
			handle_janken()
		BattleEnum.SelectMode.DIRECTION:
			hand_direction_selector_node.hide_label()
			handle_hoi()


## 選択がやり直しになったときに両者で呼ばれる
func _on_select_mode_restarted(mode: BattleEnum.SelectMode) -> void:
	match mode:
		BattleEnum.SelectMode.HAND:
			effect_manager_node.hide_janken()
			hand_direction_selector_node.start_janken()
		BattleEnum.SelectMode.DIRECTION:
			# 二連撃などで、同じじゃんけんの勝敗のままもう一度攻撃する
			start_attack_step()
	
## 残ターンが0になったときに呼ばれる処理
func turn_limit_reached() -> void:
	var host_status:PlayerStatus = player_status_list[BattleEnum.Player.HOST]
	var join_status:PlayerStatus = player_status_list[BattleEnum.Player.JOIN]

	# ゼロ除算を防ぎつつHP割合（0.0 〜 1.0）を計算
	var host_ratio: float = float(host_status.hp) / float(host_status.hp_max) if host_status.hp_max > 0 else 0.0
	var join_ratio: float = float(join_status.hp) / float(join_status.hp_max) if join_status.hp_max > 0 else 0.0

	var winner: BattleEnum.Winner

	if host_ratio > join_ratio:
		winner = BattleEnum.Winner.HOST
	elif join_ratio > host_ratio:
		winner = BattleEnum.Winner.JOIN
	else:
		winner = BattleEnum.Winner.DRAW

	GameSession.finish_battle(winner)


func _on_action_selector_attack_selected() -> void:
	GameSession.submit(BattleEnum.SelectMode.ACTION, BattleEnum.Action.ATTACK)
	action_selector_node.visible = false


func _on_action_selector_skill_selected() -> void:
	GameSession.submit(BattleEnum.SelectMode.ACTION, BattleEnum.Action.SKILL)
	action_selector_node.visible = false

func _on_action_selector_catchphrase_selected() -> void:
	GameSession.submit(BattleEnum.SelectMode.ACTION, BattleEnum.Action.CATCHPHRASE)
	action_selector_node.visible = false

func _on_hand_direction_selector_direction_selected(directions: Array[BattleEnum.Direction]) -> void:
	GameSession.submit_multi_value(BattleEnum.SelectMode.DIRECTION, directions)


func _on_hand_direction_selector_hands_selected(hand: BattleEnum.Hand) -> void:
	GameSession.submit(BattleEnum.SelectMode.HAND, hand)
