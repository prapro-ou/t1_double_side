extends Node

var chara_selections:Dictionary[int,StringName] = {}

@rpc("authority", "call_local", "reliable")
func start_game() -> void:
	NetworkManager.disconnect_signaling()
	reset_chara_selections()
	SceneManager.change_scene("chara_select")

@rpc("authority", "call_local", "reliable")
func start_battle() -> void:
	SceneManager.change_scene("battle")

#--------------------------------------------
# Chara選択について
#--------------------------------------------
#region
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
# 攻撃かスキルか選択について
#--------------------------------------------
#region

var action_selected:Dictionary[BattleEnum.Player,bool] = {}

## peer_idをHOST/JOINに正規化する。ホストは常にpeer_id 1
func to_player(peer_id:int) -> BattleEnum.Player:
	return BattleEnum.Player.HOST if peer_id == 1 else BattleEnum.Player.JOIN

## 行動選択をやり直せる状態に戻す。ラウンドごとに呼ぶ
## キーごと消すと参照側が壊れるため、clearせずfalseを入れ直す
func reset_action_selected() -> void:
	action_selected[BattleEnum.Player.HOST] = false
	action_selected[BattleEnum.Player.JOIN] = false

func is_all_action_selected() -> bool:
	return not action_selected.is_empty() and not action_selected.values().has(false)

## 選択完了を宣言する。自分の分はローカルで記録し、相手にはRPCで伝える
func submit_action_selected() -> void:
	_apply_action_selected(multiplayer.get_unique_id())
	done_action_select.rpc()

@rpc("any_peer","call_remote", "reliable")
func done_action_select() -> void:
	_apply_action_selected(multiplayer.get_remote_sender_id())

func _apply_action_selected(peer_id:int) -> void:
	action_selected[to_player(peer_id)] = true

#endregion
