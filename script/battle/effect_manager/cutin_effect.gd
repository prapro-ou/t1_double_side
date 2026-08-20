extends Node2D

@export var catchphrase_fontsize:int = 30
@export var description_fontsize:int = 20

@onready var color_rect_node:ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label_back_node:TextureRect = $LabelBack
@onready var label_node:Label = $LabelBack/Label
@onready var sprite2d_node:Sprite2D = $Sprite2D

func play_cutin(chara:CharaData) -> void:
	sprite2d_node.position = Vector2(-600,207)
	label_back_node.hide()
	label_node.add_theme_font_size_override("font_size", catchphrase_fontsize)
	
	sprite2d_node.texture = chara.cutin
	label_node.text = chara.catchphrase

	show()
	
	await get_tree().create_timer(1).timeout
	
	animation_player.play("cutin")
	await animation_player.animation_finished
	
	label_node.add_theme_font_size_override("font_size", description_fontsize)
	label_node.text = chara.catchphrase_description
	await get_tree().create_timer(5).timeout
	
	hide()
