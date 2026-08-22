extends Node2D

signal direction_selected(direction:Array[BattleEnum.Direction])
signal progress_changed(current:int, total:int) 

## DirectionArrow の snap_angles_deg = [0(上), -90(左), 180(下), 90(右)] と同順
const INDEX_TO_DIRECTION := [BattleEnum.Direction.UP, BattleEnum.Direction.LEFT, BattleEnum.Direction.DOWN, BattleEnum.Direction.RIGHT]

@onready var arrow_node:SelectArrow = $DirectionArrow

@onready var se_player_node:AudioStreamPlayer = $SEPlayer
@onready var error_se_node:AudioStreamPlayer = $ErrorSE

## 今回の選択で選ぶ方向の数
var required_count:int = 1

## すでに選んだ方向
var selected_directions:Array[BattleEnum.Direction] = []

func set_activity(is_active:bool) -> void:
	arrow_node.is_active = is_active

func start_select(count:int) -> void:
	required_count = clampi(count,1,INDEX_TO_DIRECTION.size())
	selected_directions.clear()
	progress_changed.emit(1, required_count) 
	
func _on_direction_arrow_selected(index: int) -> void:
	var direction:BattleEnum.Direction = INDEX_TO_DIRECTION[index]
	if selected_directions.has(direction):
		error_se_node.play()
		return
	
	se_player_node.play()
	selected_directions.append(direction)
	
	if selected_directions.size() < required_count:
		progress_changed.emit(selected_directions.size() + 1, required_count)
		return
	
	direction_selected.emit(selected_directions.duplicate())
