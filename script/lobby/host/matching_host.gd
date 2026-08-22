extends Control

const WAITING_TEXT:String = "参加者を待っています..."
const CONNECTING_TEXT:String = "接続中..."

@onready var join_label_node:Label = $JoinLabel
@onready var password_label_node:Label = $PasswordLabel
@onready var start_button_node:Button = $StartButton

## シグナリングサーバーから通知されたピア名（WebRTC接続の確立前から入る）
var peer_names:Dictionary[int,String] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	join_label_node.text = "対戦相手："
	password_label_node.text = "パスワード："

func setup(password:String) -> void:
	_set_start_enabled(false)
	password_label_node.text = "パスワード：" + password
	join_label_node.text =  "対戦相手：" +WAITING_TEXT
	NetworkManager.peer_joined.connect(_on_peer_joined)
	NetworkManager.peer_left.connect(_on_peer_left)
	# WebRTCのP2P接続が実際に確立/切断されたタイミング
	multiplayer.peer_connected.connect(_on_multiplayer_peer_connected)
	multiplayer.peer_disconnected.connect(_on_multiplayer_peer_disconnected)

func _set_start_enabled(enabled:bool) -> void:
	start_button_node.disabled = not enabled
	start_button_node.visible = enabled

func _reset_to_waiting() -> void:
	join_label_node.text = "対戦相手：" + WAITING_TEXT
	_set_start_enabled(false)

## シグナリングサーバー経由の参加通知。
## この時点ではまだWebRTCの接続が確立しておらずRPCが届かないため、開始ボタンは有効にしない
func _on_peer_joined(id:int,username:String) -> void:
	peer_names[id] = username
	join_label_node.text = "対戦相手：" + CONNECTING_TEXT

func _on_peer_left(id:int,_username:String) -> void:
	peer_names.erase(id)
	if multiplayer.get_peers().is_empty():
		_reset_to_waiting()

## WebRTCのP2P接続が確立した。ここで初めてRPCが相手に届くようになる
func _on_multiplayer_peer_connected(id:int) -> void:
	join_label_node.text = "対戦相手：" + peer_names.get(id, CONNECTING_TEXT)
	_set_start_enabled(true)

func _on_multiplayer_peer_disconnected(id:int) -> void:
	peer_names.erase(id)
	if multiplayer.get_peers().is_empty():
		_reset_to_waiting()

func _on_start_button_pressed() -> void:
	# 接続済みのピアがいない状態で開始すると、ホストだけがシーン遷移してしまう
	if multiplayer.get_peers().is_empty():
		_reset_to_waiting()
		return
	_set_start_enabled(false)
	DecidedSePlayer.play()
	GameSession.start_game.rpc()
