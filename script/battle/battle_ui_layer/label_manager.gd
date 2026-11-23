extends Control

@onready var label_node:Label = $Panel/Label

## ドラッグ中に指示文の代わりに出す文字。添字は「矢印の長さ(frame) - 1」
## （frame 0 = 伸びていないときは元の指示文を出す）
const DRAGGING_TEXT:Array[String] = [
	"もっと引っ張れ",
	"さらに引っ張れ",
	"はなして決定！"
]

## 引っ張っていない状態のテキスト
var no_charge_text:String

## 表示中の指示文
var base_text:String = ""

## 「（2 / 3 回目）」のような進捗表示。1回だけのときは空
var progress_text:String = ""

func show_label(text:String) -> void:
	base_text = text
	no_charge_text = text
	progress_text = ""
	_refresh()
	show()

func set_drag_level(level:int) -> void:
	if level <= 0:
		base_text = no_charge_text
	else:
		base_text = DRAGGING_TEXT[level - 1]
	_refresh()

## 今から何回目を選ぶかを表示する。1回だけのときは進捗を出さない
func set_progress(current:int,total:int) -> void:
	progress_text = "" if total <= 1 else "（%d / %d）" % [current, total]
	_refresh()

func _refresh() -> void:
	label_node.text = base_text if progress_text.is_empty() else base_text + "\n" + progress_text
