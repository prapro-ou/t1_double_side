extends Node2D

signal direction_selected(direction:BattleEnum.Direction)

## DirectionArrow の snap_angles_deg = [0(上), -90(左), 180(下), 90(右)] と同順
const INDEX_TO_DIRECTION := [BattleEnum.Direction.UP, BattleEnum.Direction.LEFT, BattleEnum.Direction.DOWN, BattleEnum.Direction.RIGHT]

@onready var arrow_node:SelectArrow = $DirectionArrow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_activity(is_active:bool) -> void:
	arrow_node.is_active = is_active


func _on_direction_arrow_selected(index: int) -> void:
	direction_selected.emit(INDEX_TO_DIRECTION[index])
