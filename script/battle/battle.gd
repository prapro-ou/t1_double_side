extends Node2D

const HandDirectionSelector = preload("res://script/battle/battle_ui_layer/hand_direction_selector.gd")
const ActionSelector = preload("res://script/battle/UI/action_selector.gd")

enum Player{
	HOST,
	JOIN
}

var host_hp:int = 0
var join_hp:int = 0

@onready var player_chara_node:CharaBase = $CharaManager/PlayerChara
@onready var opponent_chara_node:CharaBase = $CharaManager/OpponentChara

@onready var hand_direction_selector_node:HandDirectionSelector = $SelectorLayer/HandDirectionSelector
@onready var action_selector_node:ActionSelector = $SelectorLayer/ActionSelector

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func submit_action(action_id) -> void:
	if multiplayer.is_server():
		pass
	else:
		pass


## recent_hp_data = { Player.Host: "Hostの体力", Player.JOIN:"Joinの体力"}
func play_damage_effect(recent_hp_data:Dictionary[Player,int],target:Player) -> void:
	pass


func _on_action_selector_attack_selected() -> void:
	pass # Replace with function body.


func _on_action_selector_skill_selected() -> void:
	pass # Replace with function body.


func _on_hand_direction_selector_direction_selected(direction: BattleEnum.Direction) -> void:
	pass # Replace with function body.


func _on_hand_direction_selector_hands_selected(hand: BattleEnum.Hand) -> void:
	pass # Replace with function body.
