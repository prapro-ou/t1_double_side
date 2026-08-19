class_name CharaDB

## chara_idからCharaDataを引くための一覧。キャラを追加したらここにも登録する
const _DATA:Dictionary[StringName,CharaData] = {
	&"fire_man": preload("res://data/chara/fire_man.tres"),
	&"guard_man": preload("res://data/chara/guard_man.tres"),
	&"logic_woman": preload("res://data/chara/logic_woman.tres"),
}

## 指定したIDのキャラデータを返す。未登録のIDならnull
static func get_data(chara_id:StringName) -> CharaData:
	if not _DATA.has(chara_id):
		return null
	return _DATA[chara_id]
