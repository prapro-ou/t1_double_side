class_name GuardManData
extends CharaData

@export_group("スキル")
## 「デュアルガード」でガードできる方向の数
@export var skill_guard_direction_count:int = 2

@export_group("決め台詞")
## 成功時、永続で自分が受けるダメージにかかる倍率。1.0未満で防御力アップ
@export var catchphrase_success_damage_taken_rate:float = 0.8
## 失敗時、永続で自分が受けるダメージにかかる倍率。1.0より大きいと防御力ダウン
@export var catchphrase_fail_damage_taken_rate:float = 1.2
