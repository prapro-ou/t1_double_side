class_name FireManData
extends CharaData

@export_group("スキル")
## 「二連撃」で攻撃する回数
@export var skill_attack_count:int = 2

@export_group("決め台詞")
## 成功時、相手のガードを無視して与えるダメージの倍率
@export var catchphrase_success_damage_rate:float = 1.5
## 失敗時、自分が受けるダメージの倍率
@export var catchphrase_fail_damage_taken_rate:float = 1.5
