extends Node2D

# --- ノードの参照 ---
@onready var turn_label: Label = $"Turn Label" if has_node("Turn Label") else null
@onready var hp_bar: ProgressBar = $HP # HPバーノードを取得

# --- ステータス変数 ---
@export var max_hp: int = 100
var current_hp: int

func _ready() -> void:
	# ゲーム開始時にHPを最大値にセット
	current_hp = max_hp
	update_hp_display()

# --- ターン表示の更新 ---
func update_turn_display(turn: int) -> void:
	if turn_label:
		turn_label.text = "残りターン " + str(turn)

# --- HP表示の更新 ---
func update_hp_display() -> void:
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp

# --- ダメージを受ける処理（ここを外部から呼ぶ） ---
func take_damage(amount: int) -> void:
	if current_hp <= 0:
		return

	# HPを減らす
	current_hp -= amount
	current_hp = max(current_hp, 0) # 0未満にならないように補正
	
	# UIの表示を更新
	update_hp_display()
	
	# ダメージモーション演出（画面・ノードの揺れ）
	play_damage_animation()
	
	# HPが0になったかの判定
	if current_hp <= 0:
		on_defeat()

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

# --- 敗北（HP0）時の処理 ---
func on_defeat() -> void:
	print("勝負あり！HPが0になりました。")
	# ここにゲームオーバー画面を表示する処理などを追加できます
