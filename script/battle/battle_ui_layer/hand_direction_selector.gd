extends Node2D

signal direction_selected(direction: BattleEnum.Direction)
signal hands_selected(hand: BattleEnum.Hand)

const Hands = preload("res://script/battle/battle_ui_layer/hands.gd")
const Direction =preload("res://script/battle/battle_ui_layer/direction.gd")
const LabelManager = preload("res://script/battle/battle_ui_layer/label_manager.gd")

@onready var hands_node:Hands = $Hands
@onready var direction_node:Direction = $Direction
@onready var label_manager_node:LabelManager = $LabelManager

func change_janken_activate(active:bool) -> void:
	hands_node.visible = active
	hands_node.set_activity(active)

func change_direction_activate(activate:bool) -> void:
	direction_node.visible = activate
	direction_node.set_activity(activate)

## じゃんけんの手の選択を開始
func start_janken() -> void:
	label_manager_node.show_label("じゃんけんの手をドラッグで選べ！")
	change_janken_activate(true)
	change_direction_activate(false)

## ホイする方向の選択を開始
func start_direction(is_attacker:bool,count:int = 1) -> void:
	if is_attacker:
		label_manager_node.show_label("攻撃する方向をドラッグで選べ！")
	else:
		label_manager_node.show_label("相手の攻撃方向をドラッグで予測せよ！")
	
	change_janken_activate(false)
	change_direction_activate(true)
	# start_select の中から progress_changed が飛び、ラベルに「n / m 回目」が付く
	direction_node.start_select(count)

## 自分は選び終わったので、相手が選ぶまで待たせる
func show_waiting() -> void:
	label_manager_node.show_label("相手の選択を待機中…")

## 両者の選択が出揃ったときに呼ぶ
func hide_label() -> void:
	label_manager_node.hide()

func _on_direction_progress_changed(current: int, total: int) -> void:
	label_manager_node.set_progress(current,total)


func _on_direction_direction_selected(direction: Array[BattleEnum.Direction]) -> void:
	change_direction_activate(false)
	show_waiting()
	direction_selected.emit(direction)


func _on_hands_hands_selected(hand: BattleEnum.Hand) -> void:
	change_janken_activate(false)
	show_waiting()
	hands_selected.emit(hand)
