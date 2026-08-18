extends Control

const StatusDisplay = preload("res://script/battle/UI/status_display/status_display.gd")

@onready var player_status_node:StatusDisplay = $PlayerStatusDisplay
@onready var opponent_status_node:StatusDisplay = $OpponentStatusDisplay

## 指定プレイヤーのステータス表示ノードを返す。自分のものは常に手前側に出る
func _status_of(player:BattleEnum.Player) -> StatusDisplay:
	return player_status_node if GameSession.is_self(player) else opponent_status_node

func set_hp(host_hp:int,join_hp:int) -> void:
	_status_of(BattleEnum.Player.HOST).update_hp_display(host_hp)
	_status_of(BattleEnum.Player.JOIN).update_hp_display(join_hp)

func set_mp(host_mp:int,join_mp:int) -> void:
	_status_of(BattleEnum.Player.HOST).update_mp_display(host_mp)
	_status_of(BattleEnum.Player.JOIN).update_mp_display(join_mp)

func set_username(host_username:String,join_username:String) -> void:
	_status_of(BattleEnum.Player.HOST).set_username(host_username)
	_status_of(BattleEnum.Player.JOIN).set_username(join_username)

func set_chara(host_chara:CharaData, join_chara:CharaData) -> void:
	_status_of(BattleEnum.Player.HOST).set_chara(host_chara)
	_status_of(BattleEnum.Player.JOIN).set_chara(join_chara)

func play_damage(target:BattleEnum.Player) -> void:
	_status_of(target).play_damage_animation()
