extends Control

# --- ノードの参照 ---
@onready var user_name_label:Label = $UserName
@onready var chara_name_label:Label = $CharaName
@onready var hp_bar:ProgressBar = $HP
@onready var hp_label:Label = $HP/HpLabel
@onready var mp_bar:ProgressBar = $MP
@onready var mp_label:Label = $MP/MpLabel

func generate_label_text(current_value:float,max_value:float) -> String:
	return str(current_value) + "/" + str(max_value)

func set_username(username:String) -> void:
	user_name_label.text = username

#ステータス表示を初期化
func set_chara(chara: CharaData) -> void:
	
	chara_name_label.text = chara.display_name
	
	hp_bar.max_value = chara.max_hp
	mp_bar.max_value = chara.max_mp
	
	hp_bar.value = chara.max_hp
	mp_bar.value = chara.max_mp
	
	hp_label.text = generate_label_text(hp_bar.value,hp_bar.max_value)
	mp_label.text = generate_label_text(mp_bar.value,mp_bar.max_value)

# --- HP表示の更新 ---
func update_hp_display(current_hp: int) -> void:
	if hp_bar:
		hp_bar.value = current_hp
		hp_label.text = generate_label_text(hp_bar.value,hp_bar.max_value)

#MPの現在値を変更
func update_mp_display(current_mp: int) -> void:
	if mp_bar:
		mp_bar.value = current_mp
		mp_label.text = generate_label_text(mp_bar.value,mp_bar.max_value)

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
