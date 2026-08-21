extends CanvasLayer

func _ready() -> void:
	NetworkManager.leave()

func _on_go_title_pressed() -> void:
	# 2. シーンマネージャを使ってタイトルへ移動
	SceneManager.change_scene("title")
