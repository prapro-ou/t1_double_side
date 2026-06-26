extends Control

@onready var host_label_node:Label = $HostLabel
@onready var password_label_node:Label = $PasswordLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	host_label_node.text = ""
	password_label_node.text = ""

func setup(hostname:String,password:String) -> void:
	host_label_node.text = hostname;
	password_label_node.text = password
