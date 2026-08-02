extends Control
class_name StatusDisplay

# --- ノードの参照 ---
@onready var hp_bar: ProgressBar = $HP # HPバーノードを取得

# --- HP表示の更新 ---
func update_hp_display(current_hp: int, max_hp: int) -> void:
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp

# --- ダメージ時のモーション演出（Tweenを使った揺れ処理） ---
func play_damage_animation() -> void:
	# Tweenを使ってStatusDisplay全体（または指定ノード）を小刻みに揺らす
	var tween = create_tween()
	var original_pos = position
	
	# 左右にササッと揺らす演出
	tween.tween_property(self, "position", original_pos + Vector2(-10, 0), 0.05)
	tween.tween_property(self, "position", original_pos + Vector2(10, 0), 0.05)
	tween.tween_property(self, "position", original_pos + Vector2(-5, 0), 0.05)
	tween.tween_property(self, "position", original_pos + Vector2(0, 0), 0.05)
