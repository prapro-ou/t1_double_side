extends CanvasLayer

const Hands = preload("res://script/battle/battle_ui_layer/hands.gd")
const Direction =preload("res://script/battle/battle_ui_layer/direction.gd")

@onready var hands_node:Hands = $Hands
@onready var direction_node:Direction = $Direction


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## BattleUILayerを表示し、一連の選択を開始
func setup() -> void:
	pass

## じゃんけんの手の選択を開始
func start_janken() -> void:
	hands_node.visible = true
	direction_node.visible = false
	hands_node.set_activity(true)
	direction_node.set_activity(false)

## ホイする方向の選択を開始
func start_direction() -> void:
	hands_node.visible = false
	direction_node.visible = true
	hands_node.set_activity(false)
	direction_node.set_activity(true)


func _on_direction_direction_selected(direction: BattleEnum.Direction) -> void:
	pass # Replace with function body.


func _on_hands_hands_selected(hand: BattleEnum.Hand) -> void:
	pass # Replace with function body.
