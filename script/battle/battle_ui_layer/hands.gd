extends Node2D

signal hands_selected(hand:BattleEnum.Hand)

## 最大まで狙われている手の拡大倍率（元スケールに対する係数）
const HIGHLIGHT_FACTOR := 1.5

## JankenArrow の snap_angles_deg = [0(グー), -120(チョキ), 120(パー)] と同順
const INDEX_TO_HAND := [BattleEnum.Hand.GU, BattleEnum.Hand.CHOKI, BattleEnum.Hand.PA]

## JankenArrow の snap_angles_deg と同じ順番で並べること（0=グー, -120=チョキ, 120=パー）
@onready var janken_hands: Array[Sprite2D] = [
	$JankenGu,
	$JankenChoki,
	$JankenPa,
]

@onready var arrow_node:SelectArrow = $JankenArrow

@onready var se_player_node:AudioStreamPlayer = $SEPlayer

## 各手の元のスケール（拡大の基準）
var _base_scales: Array[Vector2] = []


func _ready() -> void:
	for h in janken_hands:
		_base_scales.append(h.scale)

func set_activity(is_active:bool) -> void:
	arrow_node.is_active = is_active

## 最大まで狙われている手だけ拡大し、他は元に戻す（index が -1 なら全部戻す）
func _on_janken_arrow_charge_max_changed(index: int) -> void:
	for i in janken_hands.size():
		var factor: float = HIGHLIGHT_FACTOR if i == index else 1.0
		janken_hands[i].scale = _base_scales[i] * factor


func _on_janken_arrow_selected(index: int) -> void:
	se_player_node.play()
	hands_selected.emit(INDEX_TO_HAND[index])
