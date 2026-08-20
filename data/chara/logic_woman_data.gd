class_name LogicWomanData
extends CharaData

@export_group("スキル")
## 「マジックパリィ」のカウンターで与えるダメージの倍率
@export var skill_counter_damage_rate:float = 1.0

@export_group("決め台詞")
## 成功時、相手の現在MPから奪う割合。1.0で全て奪う
@export var catchphrase_success_mp_drain_rate:float = 1.0
## 失敗時、相手の最大MPに対して与えるMPの割合。1.0で満タンになる
@export var catchphrase_fail_mp_up_rate:float = 1.0
