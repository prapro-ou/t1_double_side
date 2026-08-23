extends Node2D

func _on_button_pressed() -> void:
	DecidedSePlayer.play()
	SceneManager.change_scene("title")


func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)
