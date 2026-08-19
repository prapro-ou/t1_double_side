extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label_back_node:TextureRect = $LabelBack
@onready var label_node:Label = $LabelBack/Label


func play_cutin() -> void:
	animation_player.play("cutin")

func set_label(chara:CharaData) -> void:
	label_node.text = chara.catchprase
