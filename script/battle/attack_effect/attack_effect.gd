extends Node2D

@onready var anim_player_node:AnimationPlayer = $AnimationPlayer

@onready var guard_shield_node:Sprite2D = $GuardShield

enum Side{
	PLAYER,
	OPPONENT
}

const SHIELD_POSITION:Dictionary[int,Vector2] = {
	Side.PLAYER:Vector2(312,430),
	Side.OPPONENT:Vector2(820,158)
}

func play_attack(player_is_attacker:bool) -> void:
	if player_is_attacker:
		anim_player_node.play("player_attack")
	else:
		anim_player_node.play("opponent_attack")
	
	await anim_player_node.animation_finished

func play_guard(player_is_attacker:bool) -> void:
	if player_is_attacker:
		guard_shield_node.position = SHIELD_POSITION[Side.OPPONENT]
	else:
		guard_shield_node.position = SHIELD_POSITION[Side.PLAYER]
	
	guard_shield_node.visible = true
	
	await play_attack(player_is_attacker)
	await get_tree().create_timer(1).timeout
	
	guard_shield_node.visible = false
	
