extends Node2D

@onready var player_chara_node:CharaBase = $PlayerChara
@onready var opponent_chara_node:CharaBase = $OpponentChara

## 指定プレイヤーのキャラノードを返す。自分のキャラは常に手前側に出る
func _chara_of(player:BattleEnum.Player) -> CharaBase:
	return player_chara_node if GameSession.is_self(player) else opponent_chara_node

## 選択されたキャラの見た目を両者ぶん読み込む
func set_chara(host_chara:CharaData, join_chara:CharaData) -> void:
	_chara_of(BattleEnum.Player.HOST).set_chara(host_chara)
	_chara_of(BattleEnum.Player.JOIN).set_chara(join_chara)

## ダメージを受けた側のキャラを揺らす
func play_damage(target:BattleEnum.Player,damage:int) -> void:
	_chara_of(target).play_damage(damage)

## MPが増えた側のキャラに数字を出す
func play_mp(target:BattleEnum.Player,mp:int) -> void:
	_chara_of(target).play_mp(mp)

## HPが0になった側のキャラを倒れさせる。演出が終わるまで待てる
func play_dead(target:BattleEnum.Player) -> void:
	await _chara_of(target).play_dead()
