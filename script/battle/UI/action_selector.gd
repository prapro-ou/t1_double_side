extends Control

signal attack_selected
signal skill_selected

# 各ノードへの参照
@onready var skill_button: Button = $HBoxContainer/SkillButton
@onready var catchphrase_button: Button = $HBoxContainer/CatchphraseButton
@onready var skill_info_container: Control = $VBoxContainer  # 親コンテナ

# 各ラベルへの参照
@onready var skill_name_label: Label = $VBoxContainer/SkillNameLabel
@onready var skill_description_label: Label = $VBoxContainer/SkillDescriptionLabel
@onready var catchphrase_name_label: Label = $VBoxContainer/CatchphraseNameLabel
@onready var catchphrase_description_label: Label = $VBoxContainer/CatchphraseDescriptionLabel

func _ready() -> void:
	# 最初は親コンテナを隠しておく
	skill_info_container.hide()

	# スキルボタンのイベント接続
	skill_button.mouse_entered.connect(_on_skill_button_hover)
	skill_button.mouse_exited.connect(_on_skill_button_unhover)
	skill_button.focus_entered.connect(_on_skill_button_hover)
	skill_button.focus_exited.connect(_on_skill_button_unhover)

	# 決め台詞ボタンのイベント接続
	catchphrase_button.mouse_entered.connect(_on_catchphrase_button_hover)
	catchphrase_button.mouse_exited.connect(_on_catchphrase_button_unhover)
	catchphrase_button.focus_entered.connect(_on_catchphrase_button_hover)
	catchphrase_button.focus_exited.connect(_on_catchphrase_button_unhover)


# --- スキル情報の設定関数 (Issueの指定通り set_skil) ---
func set_skil(skill_name: String, description: String) -> void:
	if not is_node_ready():
		await ready

	# スキルボタン自体のテキスト変更
	skill_button.text = skill_name
	
	# スキル用ラベルの中身を更新
	skill_name_label.text = skill_name
	skill_description_label.text = description

func finish_battle(winner:BattleEnum.Player) -> void:
	pass

# --- ホバー/フォーカス時の処理 ---
func _on_skill_button_hover() -> void:
	# スキル用ラベルを表示し、決め台詞用ラベルを非表示
	skill_name_label.show()
	skill_description_label.show()
	catchphrase_name_label.hide()
	catchphrase_description_label.hide()
	
	skill_info_container.show()

func _on_skill_button_unhover() -> void:
	skill_info_container.hide()

func _on_catchphrase_button_hover() -> void:
	# 決め台詞用ラベルを表示し、スキル用ラベルを非表示
	skill_name_label.hide()
	skill_description_label.hide()
	catchphrase_name_label.show()
	catchphrase_description_label.show()
	
	skill_info_container.show()

func _on_catchphrase_button_unhover() -> void:
	skill_info_container.hide()

# --- ボタン押下時 ---
func _on_attack_button_pressed() -> void:
	attack_selected.emit()

func _on_skill_button_pressed() -> void:
	skill_selected.emit()

func _on_catchphrase_button_pressed() -> void:
	pass 
