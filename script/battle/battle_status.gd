class_name BattleStatus

extends Node

## 決め台詞を使用済みかどうか。決め台詞は一戦につき一回だけ使える
var catchphrase_used:Dictionary[BattleEnum.Player, bool] = {
	BattleEnum.Player.HOST: false,
	BattleEnum.Player.JOIN: false,
}

var host_pending_flag:Dictionary[BattleEnum.PendingFlag, bool] = {}
var join_pending_flag:Dictionary[BattleEnum.PendingFlag, bool] = {}

var host_turn_flag:Dictionary[BattleEnum.TurnFlag, bool] = {}
var join_turn_flag:Dictionary[BattleEnum.TurnFlag, bool] = {}

var host_permanence_flag:Dictionary[BattleEnum.PermanenceFlag, bool] = {}
var join_permanence_flag:Dictionary[BattleEnum.PermanenceFlag, bool] = {}

func add_pending_flag(target:BattleEnum.Player,flag:BattleEnum.PendingFlag) -> void:
	var target_list:Dictionary[BattleEnum.PendingFlag, bool] = host_pending_flag if target == BattleEnum.Player.HOST else join_pending_flag

	target_list[flag] = true

func get_pending_flag(target:BattleEnum.Player, flag:BattleEnum.PendingFlag) -> bool:
	var target_list:Dictionary[BattleEnum.PendingFlag, bool] = host_pending_flag if target == BattleEnum.Player.HOST else join_pending_flag
	
	return target_list.get(flag,false)

## flagがtrueならそれを削除しつつtrueを返す。falseならfalseを返す
func consume_pending_flag(target:BattleEnum.Player,flag:BattleEnum.PendingFlag) -> bool:
	var target_list:Dictionary[BattleEnum.PendingFlag, bool] = host_pending_flag if target == BattleEnum.Player.HOST else join_pending_flag
	var result:bool = get_pending_flag(target,flag)
	
	if result:
		target_list.erase(flag)
	
	return result

func add_turn_flag(target:BattleEnum.Player, flag:BattleEnum.TurnFlag) -> void:
	var target_list:Dictionary[BattleEnum.TurnFlag, bool] = host_turn_flag if target == BattleEnum.Player.HOST else join_turn_flag
	target_list[flag] = true

func get_turn_flag(target:BattleEnum.Player, flag:BattleEnum.TurnFlag) -> bool:
	var target_list:Dictionary[BattleEnum.TurnFlag, bool] = host_turn_flag if target == BattleEnum.Player.HOST else join_turn_flag
	
	return target_list.get(flag,false)

## 両者のターン終了時に消えるフラグを消す
func clear_turn_flag() -> void:
	host_turn_flag.clear()
	join_turn_flag.clear()

func add_permanence_flag(target:BattleEnum.Player, flag:BattleEnum.PermanenceFlag) -> void:
	var target_list:Dictionary[BattleEnum.PermanenceFlag, bool] = host_permanence_flag if target == BattleEnum.Player.HOST else join_permanence_flag
	target_list[flag] = true

func get_permanence_flag(target:BattleEnum.Player, flag:BattleEnum.PermanenceFlag) -> bool:
	var target_list:Dictionary[BattleEnum.PermanenceFlag, bool] = host_permanence_flag if target == BattleEnum.Player.HOST else join_permanence_flag
	return target_list.get(flag,false)
