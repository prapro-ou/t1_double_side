extends Control

signal attack_selected
signal skill_selected

# 各ノードへの参照
@onready var skill_button: Button = $HBoxContainer/SkillButton
@onready var skill_info_container: Control = $VBoxContainer  # スキル情報が入った親コンテナ
@onready var skill_name_label: Label = $VBoxContainer/SkillNameLabel
@onready var skill_description_label: Label = $VBoxContainer/SkillDescriptionLabel

# 保持しておくスキル情報
var current_skill_name: String = ""
var current_skill_description: String = ""

func _ready() -> void:
	# 最初は説明文を隠しておく
	skill_info_container.hide()

	# スキルボタンにマウスが載った/離れた時、フォーカスが当たった/外れた時のイベントを接続
	skill_button.mouse_entered.connect(_on_skill_button_hover)
	skill_button.mouse_exited.connect(_on_skill_button_unhover)
	skill_button.focus_entered.connect(_on_skill_button_hover)
	skill_button.focus_exited.connect(_on_skill_button_unhover)


# --- スキル情報の設定関数 (Issueの指定通り set_skil) ---
func set_skil(skill_name: String, description: String) -> void:
	if not is_node_ready():
		await ready

	# 内部変数に保存
	current_skill_name = skill_name
	current_skill_description = description

	# スキルボタン自体のテキストもスキル名に変更
	skill_button.text = skill_name
	
	# ラベルの中身だけ更新（この時点ではまだ hide() のまま）
	skill_name_label.text = skill_name
	skill_description_label.text = description

# --- ホバー/フォーカス時の処理 ---
func _on_skill_button_hover() -> void:
	# マウスが載ったら説明文を表示する
	skill_info_container.show()

func _on_skill_button_unhover() -> void:
	# マウスが離れたら説明文を隠す
	skill_info_container.hide()

# --- ボタン押下時 ---
func _on_attack_button_pressed() -> void:
	attack_selected.emit()

func _on_skill_button_pressed() -> void:
	skill_selected.emit()
