extends Node2D

@onready var sprite2d_node:Sprite2D = $Sprite2D

func set_direction(direction:BattleEnum.Direction) -> void:
	match direction:
		BattleEnum.Direction.UP:
			sprite2d_node.rotation_degrees = 0
		BattleEnum.Direction.LEFT:
			sprite2d_node.rotation_degrees = 270
		BattleEnum.Direction.DOWN:
			sprite2d_node.rotation_degrees = 180
		BattleEnum.Direction.RIGHT:
			sprite2d_node.rotation_degrees = 90
