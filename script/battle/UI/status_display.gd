extends Control

# --- ノードの参照 ---
@onready var user_name_label = $UserName
@onready var chara_name_label = $CharaName
@onready var hp_bar = $HP
@onready var mp_bar = $MP

#ステータス表示を初期化
func setup(username: String, chara: Dictionary) -> void:
	
	user_name_label.text = username
	chara_name_label.text = chara.display_name
	
	hp_bar.max_value = chara.max_hp
	mp_bar.max_value = chara.max_mp
	
	hp_bar.value = chara.max_hp
	mp_bar.value = chara.max_mp

# --- HP表示の更新 ---
func update_hp_display(current_hp: int) -> void:
	if hp_bar:
		hp_bar.value = current_hp

#MPの現在値を変更
func update_mp(current_mp: int) -> void:
  if mp_bar:
    mp_bar.value = current_mp

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


func _ready() -> void:
	var dummy_chara = {
	"display_name": "テスト勇者",
	"max_hp": 100,
	"max_mp": 50
	}
	setup("Player No1", dummy_chara)
