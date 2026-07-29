extends Node2D

@onready var preview = $CanvasLayer/Control/Preview
@onready var name_label = $CanvasLayer/Control/NameLabel
@onready var decision_label = $CanvasLayer/Control/DecisionLabel

@onready var chara_a = $CanvasLayer/Control/CharaA
@onready var chara_b = $CanvasLayer/Control/CharaB
@onready var chara_c = $CanvasLayer/Control/CharaC

var selected = false

func _ready() -> void:
	name_label.text = ""
	decision_label.text = ""

func show_chara(button: TextureButton, name: String) -> void:
	if selected:
		return

	preview.texture = button.texture_normal
	name_label.text = name

func submit_selection(chara_id) -> void:
	if multiplayer.is_server():
		GameSession.receive_chara_selection(multiplayer.get_unique_id(), chara_id)
	else:
		GameSession.chara_submit.rpc_id(1, chara_id)

func decide_chara(button: TextureButton, chara_id: StringName) -> void:
	if selected:
		return

	selected = true
	preview.texture = button.texture_normal
	name_label.text = chara_id
	decision_label.text = chara_id + "に決定！"
	submit_selection(chara_id)

func clear_preview() -> void:
	if selected:
		return

	preview.texture = null
	name_label.text = ""

# -------------------
# マウスを乗せたとき
# -------------------

func _on_chara_a_mouse_entered() -> void:
	show_chara(chara_a, "sampleA")

func _on_chara_b_mouse_entered() -> void:
	show_chara(chara_b, "sampleB")

func _on_chara_c_mouse_entered() -> void:
	show_chara(chara_c, "sampleC")

# -------------------
# マウスが離れたとき
# -------------------

func _on_chara_a_mouse_exited() -> void:
	clear_preview()

func _on_chara_b_mouse_exited() -> void:
	clear_preview()

func _on_chara_c_mouse_exited() -> void:
	clear_preview()

# -------------------
# ボタンを押したとき
# -------------------

func _on_chara_a_pressed() -> void:
	decide_chara(chara_a, &"sampleA")

func _on_chara_b_pressed() -> void:
	decide_chara(chara_b, &"sampleB")

func _on_chara_c_pressed() -> void:
	decide_chara(chara_c, &"sampleC")
