extends CanvasLayer


func _on_go_title_pressed() -> void:
	# 1. 接続状態を初期化し、接続前の状態に戻す
	NetworkManager.leave()

	# 2. シーンマネージャを使ってタイトルへ移動
	SceneManager.change_scene("title")
