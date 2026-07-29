extends Control

@onready var turn_label: Label = $"TurnLabel"

# Called when the node enters the scene tree for the first time.

#ターン表示を更新する関数
func update_turn_display(turn) -> void:
	turn_label.text = "残りターン"+ str(turn)
#ターン消費したときに呼ぶ関数
