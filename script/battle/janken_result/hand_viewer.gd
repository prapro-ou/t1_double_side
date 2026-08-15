extends AnimatedSprite2D

## frameと手の対応
var hand_table:Dictionary[BattleEnum.Hand,int] = {
	BattleEnum.Hand.GU:0,
	BattleEnum.Hand.CHOKI:1,
	BattleEnum.Hand.PA:2
}

func set_hand(hand:BattleEnum.Hand) -> void:
	frame = hand_table[hand]
