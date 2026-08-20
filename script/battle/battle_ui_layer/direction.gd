extends Node2D

signal direction_selected(direction:Array[BattleEnum.Direction])

## DirectionArrow の snap_angles_deg = [0(上), -90(左), 180(下), 90(右)] と同順
const INDEX_TO_DIRECTION := [BattleEnum.Direction.UP, BattleEnum.Direction.LEFT, BattleEnum.Direction.DOWN, BattleEnum.Direction.RIGHT]

@onready var arrow_node:SelectArrow = $DirectionArrow

## 今回の選択で選ぶ方向の数
var required_count:int = 1

## すでに選んだ方向
var selected_directions:Array[BattleEnum.Direction] = []

func set_activity(is_active:bool) -> void:
	arrow_node.is_active = is_active

func start_select(count:int) -> void:
	required_count = clampi(count,1,INDEX_TO_DIRECTION.size())
	selected_directions.clear()
	
func _on_direction_arrow_selected(index: int) -> void:
	var direction:BattleEnum.Direction = INDEX_TO_DIRECTION[index]
	if selected_directions.has(direction):
		return
	
	selected_directions.append(direction)
	
	if selected_directions.size() < required_count:
		return
	
	direction_selected.emit(selected_directions.duplicate())
