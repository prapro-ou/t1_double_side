extends Control

# 画像（テクスチャ）の割り当て
# ※ファイルパスはご自身のプロジェクトの画像に合わせて書き換えてください
# 画像（テクスチャ）の配列（インスペクターで設定します）
@export var pages: Array[Texture2D] = []
# タイトル画面のシーンパス
@export var title_scene_path: String = "res://title.tscn"

# ノードの参照

@export var how_to_play_ima: TextureRect
@onready var title_button: BaseButton = $TitleButton
@onready var back_button: BaseButton = $BackButton
@onready var forward_button: BaseButton = $ForwardButton

var current_page: int = 0

func _ready() -> void:
	# ボタンのシグナル（クリックイベント）を接続
	back_button.pressed.connect(_on_back_button_pressed)
	forward_button.pressed.connect(_on_forward_button_pressed)
	title_button.pressed.connect(_on_title_button_pressed)
	
	# 初回表示の更新
	update_display()
"res://assets/img/how_to_play/"

# 表示とボタンの有効/無効状態を更新
func update_display() -> void:
	if pages.size() > 0:
		how_to_play_ima.texture = pages[current_page]
	
	# 最初のページなら「戻る」ボタンを非活性（押せない状態）に
	back_button.disabled = (current_page == 0)
	
	# 最後のページなら「進む」ボタンを非活性に
	forward_button.disabled = (current_page == pages.size() - 1)

# 「戻る」ボタンが押されたとき
func _on_back_button_pressed() -> void:
	if current_page > 0:
		current_page -= 1
		update_display()

# 「進む」ボタンが押されたとき
func _on_forward_button_pressed() -> void:
	if current_page < pages.size() - 1:
		current_page += 1
		update_display()

# 「タイトルに戻る」ボタンが押されたとき
func _on_title_button_pressed() -> void:
	get_tree().change_scene_to_file(title_scene_path)
