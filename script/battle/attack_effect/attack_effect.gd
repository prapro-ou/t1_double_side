extends Node2D

@onready var anim_player:AnimationPlayer = $AnimationPlayer

func play_attack(is_player:bool) -> void:
	if is_player:
		anim_player.play("player_attack")
	else:
		anim_player.play("opponent_attack")
	
	await anim_player.animation_finished
