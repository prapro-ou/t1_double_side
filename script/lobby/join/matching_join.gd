extends Control

@onready var host_label_node:Label = $HostLabel
@onready var password_label_node:Label = $PasswordLabel
@onready var back_button_node:Button = $BackButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	host_label_node.text = "対戦相手："
	password_label_node.text = "パスワード："

func setup(hostname:String,password:String) -> void:
	host_label_node.text = "対戦相手：" + hostname;
	password_label_node.text = "パスワード：" + password

func _on_back_button_pressed() -> void:
	# 連打で退出処理が二重に走らないようにする
	back_button_node.disabled = true
	DecidedSePlayer.play()
	# 黙って切断すると相手が通信エラー扱いになるので、退出を伝えてからタイトルに戻る
	GameSession.leave_to_title()
