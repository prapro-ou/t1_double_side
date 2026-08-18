extends Node


@rpc("authority", "call_local", "reliable")
func start_game() -> void:
	NetworkManager.disconnect_signaling()
	NetworkManager.begin_game()
	reset_chara_selections()
	reset_usernames()
	announce_username()
	SceneManager.change_scene("chara_select")

@rpc("authority", "call_local", "reliable")
func start_battle() -> void:
	SceneManager.change_scene("battle")


## peer_idをHOST/JOINに正規化する。ホストは常にpeer_id 1
func to_player(peer_id:int) -> BattleEnum.Player:
	return BattleEnum.Player.HOST if peer_id == 1 else BattleEnum.Player.JOIN

## 自分がHOST/JOINのどちらかを返す
func get_self_player() -> BattleEnum.Player:
	return to_player(multiplayer.get_unique_id())

## 自分から見た相手側を返す
func get_opponent_player() -> BattleEnum.Player:
	return get_other_player(get_self_player())

## 指定プレイヤーが自分かどうか
func is_self(player:BattleEnum.Player) -> bool:
	return player == get_self_player()

## 指定プレイヤーではないほうを返す
func get_other_player(player:BattleEnum.Player) -> BattleEnum.Player:
	return BattleEnum.Player.JOIN if player == BattleEnum.Player.HOST else BattleEnum.Player.HOST

#--------------------------------------------
# ゲームのフェーズの監理
#--------------------------------------------
#region

signal changed_phase(phase:BattleEnum.Phase)

var current_phase:BattleEnum.Phase

## フェーズを進める。進行権はホストのみが持つので、クライアントから呼んでも無視される
func advance_phase(phase:BattleEnum.Phase) -> void:
	if not multiplayer.is_server():
		return
	_change_phase.rpc(phase)

## 直接呼ばずadvance_phase()を使うこと。call_localなので両者で同じ順序で走る
@rpc("authority", "call_local", "reliable")
func _change_phase(phase:BattleEnum.Phase) -> void:
	current_phase = phase
	_reset_all_select_modes()
	changed_phase.emit(phase)

#endregion


#--------------------------------------------
# ユーザー名について
#--------------------------------------------
#region

## ユーザー名が増減したときに両者で発火する
signal usernames_changed()

## peer_idごとのユーザー名。ゲーム開始時に両者が名乗り合うことで埋まる
var usernames:Dictionary[int,String] = {}

## 自分のユーザー名を相手に伝える。start_game()から両者で呼ばれる
func announce_username() -> void:
	_announce_username.rpc(NetworkManager.self_username)

## 直接呼ばずannounce_username()を使うこと。call_localなので自分の分もここで登録される
@rpc("any_peer", "call_local", "reliable")
func _announce_username(username:String) -> void:
	# call_localで自分自身から呼ばれたときは送信元IDが0になる
	var peer_id:int = multiplayer.get_remote_sender_id()
	if peer_id == 0:
		peer_id = multiplayer.get_unique_id()
	usernames[peer_id] = username
	usernames_changed.emit()

## 指定プレイヤーのユーザー名を返す。まだ受け取っていなければ空
func get_username(player:BattleEnum.Player) -> String:
	for peer_id:int in usernames:
		if to_player(peer_id) == player:
			return usernames[peer_id]
	return ""

## 名乗り合う前の状態に戻す
func reset_usernames() -> void:
	usernames.clear()

#endregion

#--------------------------------------------
# Chara選択について
#--------------------------------------------
#region
var chara_selections:Dictionary[int,StringName] = {}

@rpc("any_peer", "reliable")
func chara_submit(chara_id: StringName) -> void:
	receive_chara_selection(multiplayer.get_remote_sender_id(), chara_id)

@rpc("authority", "call_local", "reliable")
func _chara_apply(peer_id: int, chara_id: StringName) -> void:
	chara_selections[peer_id] = chara_id
	print(chara_selections)



func receive_chara_selection(peer_id:int,chara_id:StringName) -> void:
	if not multiplayer.is_server():
		return
	if chara_selections.has(peer_id):
		return
	
	_chara_apply.rpc(peer_id,chara_id)

	if chara_selections.size() == multiplayer.get_peers().size() + 1:
		start_battle.rpc()

## 指定プレイヤーが選んだキャラのIDを返す。まだ選んでいなければ空
func get_chara_id(player:BattleEnum.Player) -> StringName:
	for peer_id:int in chara_selections:
		if to_player(peer_id) == player:
			return chara_selections[peer_id]
	return &""

## 指定プレイヤーが選んだキャラのデータを返す。未選択・未登録のIDならnull
func get_chara_data(player:BattleEnum.Player) -> CharaData:
	return CharaDB.get_data(get_chara_id(player))

## キャラ選択をやり直せる状態に戻す。
func reset_chara_selections() -> void:
	chara_selections.clear()

#endregion

#--------------------------------------------
# SelectMode( 行動 / じゃんけんの手 / 方向 )の選択同期について
#--------------------------------------------
#region

## 両者の値が出揃ったときに発火する。values = { BattleEnum.Player : 選んだ値 }
signal select_mode_completed(mode:BattleEnum.SelectMode, values:Dictionary)

## 選択がやり直しになったときに両者で発火する
signal select_mode_restarted(mode:BattleEnum.SelectMode)

## 自分が選んだ値。両者が選択済みになるまで送信しない
var _pending:Dictionary[BattleEnum.SelectMode,int] = {}
## 「選択済みかどうか」だけのフラグ。値は含まない
var _selected:Dictionary[BattleEnum.SelectMode,Dictionary] = {}
## 開示された実際の値
var _revealed:Dictionary[BattleEnum.SelectMode,Dictionary] = {}

## 全SelectModeの選択をやり直せる状態に戻す。change_phase()から呼ばれる
func _reset_all_select_modes() -> void:
	for mode:BattleEnum.SelectMode in BattleEnum.SelectMode.values():
		reset_select_mode(mode)

## 特定のSelectModeだけ選択をやり直せる状態に戻す。
## 両者で同じタイミングになるよう、authorityのcall_local RPC内から呼ぶこと
func reset_select_mode(mode:BattleEnum.SelectMode) -> void:
	_pending.erase(mode)
	_selected[mode] = {}
	_revealed[mode] = {}

## 特定のSelectModeだけ選び直させる。あいこのときのじゃんけんなど
## 進行権はホストのみが持つので、クライアントから呼んでも無視される
func restart_select_mode(mode:BattleEnum.SelectMode) -> void:
	if not multiplayer.is_server():
		return
	_restart_select_mode.rpc(mode)

## 直接呼ばずrestart_select_mode()を使うこと。call_localなので両者で同じ順序で走る
@rpc("authority", "call_local", "reliable")
func _restart_select_mode(mode:BattleEnum.SelectMode) -> void:
	reset_select_mode(mode)
	select_mode_restarted.emit(mode)

## 選択を宣言する。この時点では値を送らず「選んだ」ことだけを相手に伝える
func submit(mode:BattleEnum.SelectMode, value:int) -> void:
	if _pending.has(mode):
		return
	_pending[mode] = value
	_notify_selected.rpc(mode)
	_mark_selected(mode, multiplayer.get_unique_id())

## 選択したことを相手に通知するrpc関数
## @rpc("any_peer","call_remote","reliable")
@rpc("any_peer","call_remote","reliable")
func _notify_selected(mode:BattleEnum.SelectMode) -> void:
	_mark_selected(mode, multiplayer.get_remote_sender_id())

## 選択したことのフラグを建て、全部trueか調べる
func _mark_selected(mode:BattleEnum.SelectMode, peer_id:int) -> void:
	if not _selected.has(mode):
		_selected[mode] = {}
	_selected[mode][to_player(peer_id)] = true
	if is_all_selected(mode):
		_send_reveal(mode)

func is_all_selected(mode:BattleEnum.SelectMode) -> bool:
	return _selected.get(mode, {}).size() == 2

## 両者が選択済みになった瞬間に、初めて自分の値を開示する
func _send_reveal(mode:BattleEnum.SelectMode) -> void:
	if not _pending.has(mode):
		return
	var value:int = _pending[mode]
	_pending.erase(mode)
	_reveal.rpc(mode, value)
	_apply_reveal(mode, multiplayer.get_unique_id(), value)

## 相手に自身の手を通知
## @rpc("any_peer","call_remote","reliable")
@rpc("any_peer","call_remote","reliable")
func _reveal(mode:BattleEnum.SelectMode, value:int) -> void:
	_apply_reveal(mode, multiplayer.get_remote_sender_id(), value)

## 通知された手を伝える
func _apply_reveal(mode:BattleEnum.SelectMode, peer_id:int, value:int) -> void:
	if not _revealed.has(mode):
		_revealed[mode] = {}
	_revealed[mode][to_player(peer_id)] = value
	if is_completed(mode):
		select_mode_completed.emit(mode, _revealed[mode])

## 両者の値が出揃ったか
func is_completed(mode:BattleEnum.SelectMode) -> bool:
	return _revealed.get(mode, {}).size() == 2

## 指定プレイヤーが選んだ行動を返す
func get_action(player:BattleEnum.Player) -> BattleEnum.Action:
	return _get_value(BattleEnum.SelectMode.ACTION, player) as BattleEnum.Action

## 指定プレイヤーが選んだじゃんけんの手を返す
func get_hand(player:BattleEnum.Player) -> BattleEnum.Hand:
	return _get_value(BattleEnum.SelectMode.HAND, player) as BattleEnum.Hand

## 指定プレイヤーが選んだホイの方向を返す
func get_direction(player:BattleEnum.Player) -> BattleEnum.Direction:
	return _get_value(BattleEnum.SelectMode.DIRECTION, player) as BattleEnum.Direction

## 直接呼ばずget_action()などSelectModeごとの関数を使うこと
func _get_value(mode:BattleEnum.SelectMode, player:BattleEnum.Player) -> int:
	return _revealed[mode][player]

#endregion


#--------------------------------------------
# ダメージの同期について
#--------------------------------------------
#region

## ダメージが確定したときに両者で発火する。
## hp = { BattleEnum.Player.HOST: HostのHP, BattleEnum.Player.JOIN: JoinのHP }（減算後の値）
signal damage_applied(defender:BattleEnum.Player, hp:Dictionary[BattleEnum.Player,int], damage:int)

## 確定したダメージを両者に配る。HPの計算はホストのbattle.gdが行う。
## 進行権はホストのみが持つので、クライアントから呼んでも無視される
func apply_damage(defender:BattleEnum.Player, hp:Dictionary[BattleEnum.Player,int], damage:int) -> void:
	if not multiplayer.is_server():
		return
		
	_apply_damage.rpc(defender, hp, damage)

## 直接呼ばずapply_damage()を使うこと。
@rpc("authority","call_local","reliable")
func _apply_damage(defender:BattleEnum.Player, hp:Dictionary, damage:int) -> void:
	damage_applied.emit(defender, hp, damage)

#endregion
