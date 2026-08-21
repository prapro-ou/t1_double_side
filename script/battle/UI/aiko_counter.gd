extends Control

@onready var label: Label = $Panel/Label
@onready var rate_label:Label = $Panel/RateLabel


func set_count(count: int,rate :float):
	if count <= 0:
		visible = false
	else:
		visible = true
		label.text = "あいこカウント" + "%d" %count
		rate_label.text = ("ダメージ倍率" + "%0.1f" + "倍") % rate
