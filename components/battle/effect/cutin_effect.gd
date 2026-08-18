extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# Replace with function body.


func play_cutin() -> void:
	animation_player.play("cutin")
