extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_go_title_pressed() -> void:
	# 1. ポップアップ画面を削除
	queue_free()
	
	# 2. 一時停止している場合は解除
	get_tree().paused = false
	
	# 3. シーンマネージャを使ってタイトルへ移動
	SceneManager.change_scene("title")
