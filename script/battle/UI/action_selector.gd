extends Control

signal attack_selected()
signal skill_selected()
signal catchphrase_selected()

# 各ノードへの参照
@onready var attack_button: Button = $HBoxContainer/AttackButton
@onready var skill_button: Button = $HBoxContainer/SkillButton
@onready var catchphrase_button: Button = $HBoxContainer/CatchphraseButton
@onready var skill_info_container: Control = $VBoxContainer  # 親コンテナ

# 各ラベルへの参照
@onready var attack_label:Label = $VBoxContainer/AttackLabel
@onready var skill_name_label: Label = $VBoxContainer/SkillNameLabel
@onready var skill_description_label: Label = $VBoxContainer/SkillDescriptionLabel
@onready var catchphrase_name_label: Label = $VBoxContainer/CatchphraseNameLabel
@onready var catchphrase_description_label: Label = $VBoxContainer/CatchphraseDescriptionLabel

@onready var se_play:AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	# 最初は親コンテナを隠しておく
	skill_info_container.hide()
	
	# 攻撃ボタンのイベント接続
	attack_button.mouse_entered.connect(_on_attack_button_hover)
	attack_button.mouse_exited.connect(_on_attack_button_unhover)
	attack_button.focus_entered.connect(_on_attack_button_hover)
	attack_button.focus_exited.connect(_on_attack_button_unhover)

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


func set_chara(chara:CharaData) -> void:
	set_skill(chara.skill_name,chara.skill_description)
	set_catchphrase(chara.catchphrase,chara.catchphrase_description)

# --- スキル情報の設定関数 ---
func set_skill(skill_name: String, description: String) -> void:
	# スキル用ラベルの中身を更新
	skill_name_label.text = skill_name
	skill_description_label.text = description

## 決め台詞の設定関数
func set_catchphrase(catchphrase:String, description:String) -> void:
	catchphrase_name_label.text = catchphrase
	catchphrase_description_label.text = description

func set_button_disable(skill:bool, catchphrase:bool) -> void:
	skill_button.disabled = skill
	catchphrase_button.disabled = catchphrase

# --- ホバー/フォーカス時の処理 ---
func _on_attack_button_hover() -> void:
	# 攻撃用ラベルだけを表示
	attack_label.show()

	skill_name_label.hide()
	skill_description_label.hide()
	catchphrase_name_label.hide()
	catchphrase_description_label.hide()

	skill_info_container.show()

func _on_attack_button_unhover() -> void:
	skill_info_container.hide()

func _on_skill_button_hover() -> void:
	# スキル用ラベルだけを表示
	skill_name_label.show()
	skill_description_label.show()

	attack_label.hide()
	catchphrase_name_label.hide()
	catchphrase_description_label.hide()

	skill_info_container.show()

func _on_skill_button_unhover() -> void:
	skill_info_container.hide()

func _on_catchphrase_button_hover() -> void:
	# 決め台詞用ラベルだけを表示
	catchphrase_name_label.show()
	catchphrase_description_label.show()

	attack_label.hide()
	skill_name_label.hide()
	skill_description_label.hide()

	skill_info_container.show()

func _on_catchphrase_button_unhover() -> void:
	skill_info_container.hide()

# --- ボタン押下時 ---
func _on_attack_button_pressed() -> void:
	se_play.play()
	attack_selected.emit()

func _on_skill_button_pressed() -> void:
	se_play.play()
	skill_selected.emit()

func _on_catchphrase_button_pressed() -> void:
	se_play.play()
	catchphrase_selected.emit()
