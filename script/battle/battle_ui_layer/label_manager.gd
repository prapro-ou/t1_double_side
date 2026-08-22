extends Control

@onready var label_node:Label = $Panel/Label

## 指示文の本体
var base_text:String = ""

## 「（2 / 3 回目）」のような進捗表示。1回だけのときは空
var progress_text:String = ""

func show_label(text:String) -> void:
	base_text = text
	progress_text = ""
	_refresh()
	show()

## 今から何回目を選ぶかを表示する。1回だけのときは進捗を出さない
func set_progress(current:int,total:int) -> void:
	progress_text = "" if total <= 1 else "（%d / %d）" % [current, total]
	_refresh()

func _refresh() -> void:
	label_node.text = base_text if progress_text.is_empty() else base_text + "\n" + progress_text
