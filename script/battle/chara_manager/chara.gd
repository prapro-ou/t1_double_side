class_name CharaBase

extends Node2D

## 自分のキャラを表示する用のスプライトか
@export var is_player:bool

@onready var animated_sprite2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var anim_player_node:AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## 対応したキャラを読み込む
func set_chara(chara:CharaData) -> void:
	animated_sprite2d.sprite_frames = chara.sprite_frames
	

func play_damage() -> void:
	anim_player_node.play("damage")
