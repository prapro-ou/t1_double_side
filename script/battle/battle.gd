extends Node2D

enum Player{
	HOST,
	JOIN
}

var host_hp:int = 0
var join_hp:int = 0

@onready var player_chara_node:CharaBase = $CharaManager/PlayerChara
@onready var opponent_chara_node:CharaBase = $CharaManager/OpponentChara

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## recent_hp_data = { Player.Host: "Hostの体力", Player.JOIN:"Joinの体力"}
func play_damage_effect(recent_hp_data:Dictionary[Player,int],target:Player) -> void:
	pass
