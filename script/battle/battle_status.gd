class_name BattleStatus

extends Node

## プレイヤー1人分のフラグをまとめて持つ
class PlayerFlags:
	## 発動条件が満たされるのを待っているフラグ
	var pending:Dictionary[BattleEnum.PendingFlag, bool] = {}
	## そのターンの終わりに消えるフラグ
	var turn:Dictionary[BattleEnum.TurnFlag, bool] = {}
	## 一戦を通して残るフラグ
	var permanence:Dictionary[BattleEnum.PermanenceFlag, bool] = {}

## 決め台詞を使用済みかどうか。決め台詞は一戦につき一回だけ使える
var catchphrase_used:Dictionary[BattleEnum.Player, bool] = {
	BattleEnum.Player.HOST: false,
	BattleEnum.Player.JOIN: false,
}

## プレイヤーごとのフラグ
var player_flags:Dictionary[BattleEnum.Player, PlayerFlags] = {
	BattleEnum.Player.HOST: PlayerFlags.new(),
	BattleEnum.Player.JOIN: PlayerFlags.new(),
}


func add_pending_flag(target:BattleEnum.Player, flag:BattleEnum.PendingFlag) -> void:
	player_flags[target].pending[flag] = true

func get_pending_flag(target:BattleEnum.Player, flag:BattleEnum.PendingFlag) -> bool:
	return player_flags[target].pending.get(flag, false)

## flagがtrueならそれを削除しつつtrueを返す。falseならfalseを返す
func consume_pending_flag(target:BattleEnum.Player, flag:BattleEnum.PendingFlag) -> bool:
	return player_flags[target].pending.erase(flag)

func add_turn_flag(target:BattleEnum.Player, flag:BattleEnum.TurnFlag) -> void:
	player_flags[target].turn[flag] = true

func get_turn_flag(target:BattleEnum.Player, flag:BattleEnum.TurnFlag) -> bool:
	return player_flags[target].turn.get(flag, false)

## 両者のターン終了時に消えるフラグを消す
func clear_turn_flag() -> void:
	for player:BattleEnum.Player in player_flags:
		player_flags[player].turn.clear()

func add_permanence_flag(target:BattleEnum.Player, flag:BattleEnum.PermanenceFlag) -> void:
	player_flags[target].permanence[flag] = true

func get_permanence_flag(target:BattleEnum.Player, flag:BattleEnum.PermanenceFlag) -> bool:
	return player_flags[target].permanence.get(flag, false)
