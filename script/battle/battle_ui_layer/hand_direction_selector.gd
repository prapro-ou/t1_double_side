extends Node2D

signal direction_selected(direction: BattleEnum.Direction)
signal hands_selected(hand: BattleEnum.Hand)

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

func change_janken_activate(active:bool) -> void:
	hands_node.visible = active
	hands_node.set_activity(active)

func change_direction_activate(activate:bool) -> void:
	direction_node.visible = activate
	direction_node.set_activity(activate)

## じゃんけんの手の選択を開始
func start_janken() -> void:
	change_janken_activate(true)
	change_direction_activate(false)

## ホイする方向の選択を開始
func start_direction() -> void:
	change_janken_activate(false)
	change_direction_activate(true)


func _on_direction_direction_selected(direction: BattleEnum.Direction) -> void:
	change_direction_activate(false)
	direction_selected.emit(direction)
	


func _on_hands_hands_selected(hand: BattleEnum.Hand) -> void:
	change_janken_activate(false)
	hands_selected.emit(hand)
	
