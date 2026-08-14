class_name CharaDB

## chara_idからCharaDataを引くための一覧。キャラを追加したらここにも登録する
const _DATA:Dictionary[StringName,CharaData] = {
	&"sampleA": preload("res://data/chara/sample_a.tres"),
	&"sampleB": preload("res://data/chara/sample_b.tres"),
	&"sampleC": preload("res://data/chara/sample_c.tres"),
}

## 指定したIDのキャラデータを返す。未登録のIDならnull
static func get_data(chara_id:StringName) -> CharaData:
	if not _DATA.has(chara_id):
		return null
	return _DATA[chara_id]
