extends Panel

@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_count(count: int):
	if count <= 0:
		visible = false
	else:
		visible = true
		label.text = "%d" %count
