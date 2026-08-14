extends Node


@rpc("authority", "call_local", "reliable")
func start_game() -> void:
	NetworkManager.disconnect_signaling()
	NetworkManager.begin_game()
	reset_chara_selections()
	SceneManager.change_scene("chara_select")

@rpc("authority", "call_local", "reliable")
func start_battle() -> void:
	SceneManager.change_scene("battle")


## peer_idをHOST/JOINに正規化する。ホストは常にpeer_id 1
func to_player(peer_id:int) -> BattleEnum.Player:
	return BattleEnum.Player.HOST if peer_id == 1 else BattleEnum.Player.JOIN

func get_self_player() -> BattleEnum.Player:
	return to_player(multiplayer.get_unique_id())

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

func get_value(mode:BattleEnum.SelectMode, player:BattleEnum.Player):
	return _revealed[mode][player]

#endregion
