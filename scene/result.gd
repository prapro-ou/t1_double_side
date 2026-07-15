extends Node2D

@onready var result_en = $CanvasLayer/Control/Result_English
@onready var result_jp = $CanvasLayer/Control/Result_Japanese

# テスト用
@export var is_win := true

func _ready() -> void:
	set_result(is_win)

func set_result(win: bool) -> void:
	if win:
		result_en.text = "You Win!"
		result_jp.text = "あなたの勝ちです"
	else:
		result_en.text = "You Lose!"
		result_jp.text = "あなたの負けです"

func _on_re_match_pressed() -> void:
	SceneManager.change_scene("chara_select")

func _on_go_title_pressed() -> void:
	SceneManager.change_scene("title")
