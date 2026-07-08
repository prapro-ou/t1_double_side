extends Node2D

## 自分のキャラを表示する用のスプライトか
@export var is_player:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup(chara:) -> void:
	pass


## 対応したキャラを読み込む
func set_chara(chara:CharaData) -> void:
	pass
