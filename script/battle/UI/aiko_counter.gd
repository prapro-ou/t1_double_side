extends Control

@export var is_debug:bool = false

@onready var label: Label = $Panel/Label

func _ready() -> void:
	if is_debug:
		set_count(10)

func set_count(count: int):
	if count <= 0:
		visible = false
	else:
		visible = true
		label.text = "あいこカウント\n" + "%d" %count
