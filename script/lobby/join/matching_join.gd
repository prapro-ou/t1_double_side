extends Control

@onready var host_label_node:Label = $HostLabel
@onready var password_label_node:Label = $PasswordLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	host_label_node.text = "対戦相手："
	password_label_node.text = "パスワード："

func setup(hostname:String,password:String) -> void:
	host_label_node.text = "対戦相手：" + hostname;
	password_label_node.text = "パスワード：" + password
