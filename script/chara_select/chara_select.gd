extends Node2D

@onready var preview = $CanvasLayer/Control/Preview
@onready var name_back = $CanvasLayer/Control/NameBack
@onready var name_label = $CanvasLayer/Control/NameBack/NameLabel
@onready var decision_label = $CanvasLayer/Control/NameBack/DecisionLabel

@onready var chara_a = $CanvasLayer/Control/CharaA
@onready var chara_b = $CanvasLayer/Control/CharaB
@onready var chara_c = $CanvasLayer/Control/CharaC

@onready var se_player_node:AudioStreamPlayer = $SEPlayer

var selected = false

var preview_list:Dictionary[StringName,Texture2D] = {
	&"fire_man":preload("res://assets/img/chara/fire_man/fire_man.png"),
	&"guard_man":preload("res://assets/img/chara/guard_man/guard_man.png"),
	&"logic_woman":preload("res://assets/img/chara/logic_woman/logic_woman.png")
}

func _ready() -> void:
	name_back.show()
	name_label.text = "アイコンをクリックして\nキャラを選択！"
	decision_label.text = ""

func show_chara(name: StringName) -> void:
	if selected:
		return
	
	name_back.show()
	preview.texture = preview_list[name]
	name_label.text = generate_description(name)

func submit_selection(chara_id) -> void:
	if multiplayer.is_server():
		GameSession.receive_chara_selection(multiplayer.get_unique_id(), chara_id)
	else:
		GameSession.chara_submit.rpc_id(1, chara_id)

## キャラの名前・HP・攻撃力・スキル名を並べた説明文を返す。未登録のIDなら空文字
func generate_description(chara_id:StringName) -> String:
	var data:CharaData = CharaDB.get_data(chara_id)
	if data == null:
		return ""

	return "名前：%s\nHP：%d\n攻撃力：%d\nスキル：%s" % [
		data.display_name,
		data.max_hp,
		data.attack,
		data.skill_name
	]

func decide_chara(button: TextureButton, chara_id: StringName) -> void:
	if selected:
		return

	selected = true
	preview.texture = preview_list[chara_id]
	
	name_back.show()
	
	name_label.text = ""
	
	decision_label.text = CharaDB.get_data(chara_id).display_name + "に決定！" + "\n対戦相手の選択を待機中..."
	
	se_player_node.play()
	
	await get_tree().create_timer(1).timeout
	
	submit_selection(chara_id)

func clear_preview() -> void:
	if selected:
		return

	preview.texture = null
	name_label.text = "アイコンをクリックして\nキャラを選択！"

# -------------------
# マウスを乗せたとき
# -------------------

func _on_chara_a_mouse_entered() -> void:
	show_chara(&"fire_man")

func _on_chara_b_mouse_entered() -> void:
	show_chara(&"guard_man")

func _on_chara_c_mouse_entered() -> void:
	show_chara(&"logic_woman")

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
	decide_chara(chara_a, &"fire_man")

func _on_chara_b_pressed() -> void:
	decide_chara(chara_b, &"guard_man")

func _on_chara_c_pressed() -> void:
	decide_chara(chara_c, &"logic_woman")
