class_name CharaBase

extends Node2D

## 自分のキャラを表示する用のスプライトか
@export var is_player:bool

@onready var animated_sprite2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var anim_player_node:AnimationPlayer = $AnimationPlayer
@onready var label_anim_node:AnimationPlayer = $LabelAnim

@onready var damage_particles_node:GPUParticles2D = $DamageParticles2D

@onready var damage_num_node:Label = $DamageNum
@onready var mp_num_node:Label = $MpNum

@onready var damage_se_node:AudioStreamPlayer = $DamageSE
@onready var dead_se_node:AudioStreamPlayer = $DeadSE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite2d.flip_h = not is_player

## 対応したキャラを読み込む
func set_chara(chara:CharaData) -> void:
	animated_sprite2d.sprite_frames = chara.sprite_frames
	

func play_damage(damage:int) -> void:
	# LabelAnimは1つしかないので、MPの数字が出ている途中で割り込むと消し忘れる
	mp_num_node.visible = false

	damage_num_node.text = str(damage)
	label_anim_node.play("damage")

	damage_particles_node.restart()
	anim_player_node.play("damage")

func play_dead() -> void:
	dead_se_node.play()
	anim_player_node.play("dead")
	
	await anim_player_node.animation_finished
	
	await get_tree().create_timer(1).timeout

## MPの増加量を数字で出す
func play_mp(mp:int) -> void:
	damage_num_node.visible = false

	mp_num_node.text = "MP%+d" % mp
	label_anim_node.play("mp")
