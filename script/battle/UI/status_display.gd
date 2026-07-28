extends Node

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

#HPの現在値を変更
func update_hp(current_hp: int) -> void:
	hp_bar.value = current_hp

#MPの現在値を変更
func update_mp(current_mp: int) -> void:
	mp_bar.value = current_mp



func _ready() -> void:
	var dummy_chara = {
	"display_name": "テスト勇者",
	"max_hp": 100,
	"max_mp": 50
	}
	setup("Player No1", dummy_chara)
