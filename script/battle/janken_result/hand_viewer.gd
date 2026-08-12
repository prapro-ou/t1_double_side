extends AnimatedSprite2D

@onready var anim_player_node:AnimationPlayer = $AnimationPlayer

## frameと手の対応
var hand_table:Dictionary[BattleEnum.Hand,int] = {
	BattleEnum.Hand.GU:0,
	BattleEnum.Hand.CHOKI:1,
	BattleEnum.Hand.PA:2
}

func set_hand(hand:BattleEnum.Hand) -> void:
	frame = hand_table[hand]

func emphasis() -> void:
	anim_player_node.play("emphasis")
	await anim_player_node.animation_finished
	
