extends Node

var chara_selections:Dictionary[int,StringName] = {}

@rpc("authority", "call_local", "reliable")
func start_game() -> void:
	NetworkManager.disconnect_signaling()
	SceneManager.change_scene("chara_select")

@rpc("authority", "call_local", "reliable")
func start_battle() -> void:
	SceneManager.change_scene("battle")

@rpc("any_peer", "reliable")
func submit(chara_id: StringName) -> void:
	receive_selection(multiplayer.get_remote_sender_id(), chara_id)

@rpc("authority", "call_local", "reliable")
func _apply(peer_id: int, chara_id: StringName) -> void:
	chara_selections[peer_id] = chara_id
	print(chara_selections)

func receive_selection(peer_id:int,chara_id:StringName) -> void:
	if not multiplayer.is_server():
		return
	if chara_selections.has(peer_id):
		return
	
	_apply.rpc(peer_id,chara_id)

	if chara_selections.size() == multiplayer.get_peers().size() + 1:
		start_battle.rpc()
