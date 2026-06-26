extends Control

const WAITING_TEXT:String = "参加者を待っています..."

@onready var join_label_node:Label = $JoinLabel
@onready var password_label_node:Label = $PasswordLabel
@onready var start_button_node:Button = $StartButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	join_label_node.text = ""
	password_label_node.text = ""

func setup(password:String) -> void:
	start_button_node.disabled = true
	start_button_node.visible = false
	password_label_node.text = password
	join_label_node.text = WAITING_TEXT
	NetworkManager.peer_joined.connect(_on_peer_joined)
	NetworkManager.peer_left.connect(_on_peer_left)

func _on_peer_joined(_id:int,username:String) -> void:
	join_label_node.text = username
	start_button_node.disabled = false
	start_button_node.visible = true

func _on_peer_left(_id:int,_username:String) -> void:
	join_label_node.text = WAITING_TEXT
	start_button_node.disabled = true
	start_button_node.visible = false


func _on_start_button_pressed() -> void:
	SceneManager.change_scene("webrtc_test")
