extends Node2D

@export var is_player_hoi:bool = false
@export var padding:float = 300

## 方向ごとの矢印の回転角度
const DIRECTION_TO_ROTATION_DEGREES := {
	BattleEnum.Direction.UP: 0.0,
	BattleEnum.Direction.LEFT: 270.0,
	BattleEnum.Direction.DOWN: 180.0,
	BattleEnum.Direction.RIGHT: 90.0,
}

@onready var sprite2d_node:Sprite2D = $Sprite2D

## 複数表示のために複製した矢印。sprite2d_node は含まない
var sprite_node_list:Array[Sprite2D] = []


## 指した方向の矢印を横並びで表示する
func set_direction(directions:Array[BattleEnum.Direction]) -> void:
	clear_sprites()
	
	if directions.is_empty():
		push_error("HoiViewer:directionsが空です")
		return
	
	var pos_x:float = 0
	for d in directions:
		var s:Sprite2D = sprite2d_node.duplicate()
		s.position.x = pos_x
		s.rotation_degrees = DIRECTION_TO_ROTATION_DEGREES[d]
		s.visible = true
		
		add_child(s)
		sprite_node_list.push_back(s)
		
		
		
		if is_player_hoi:
			pos_x += padding
		else:
			pos_x -= padding

func clear_sprites() -> void:
	for i in sprite_node_list:
		remove_child(i)
		i.queue_free()
	
	sprite_node_list.clear()
		
