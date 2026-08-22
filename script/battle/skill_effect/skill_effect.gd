extends Node2D

@export var wait_time:float = 2.0

@onready var back_node:TextureRect = $Back
@onready var label_node:Label = $Back/Label
@onready var icon_node:TextureRect = $Back/Icon
@onready var anim_node:AnimationPlayer = $AnimationPlayer

@onready var cutin_se:AudioStreamPlayer = $CutinSE

func generate_skill_text(is_player:bool) -> String:
	if is_player:
		return "あなたのスキル発動！"
	else:
		return "相手のスキル発動！"

func generate_skill_description(chara:CharaData) -> String:
	return chara.skill_name + "\n" + chara.skill_description

func play_skill_effect(user_is_player:bool,chara:CharaData) -> void:
	show()
	
	back_node.position = Vector2(-1000,0)
	label_node.text = generate_skill_text(user_is_player)
	icon_node.texture = chara.icon
	
	cutin_se.play()
	anim_node.play("slide_in")
	await  anim_node.animation_finished
	
	await get_tree().create_timer(wait_time).timeout
	
	label_node.text = generate_skill_description(chara)
	
	await get_tree().create_timer(wait_time).timeout
	
	hide()
	
