class_name BattleEnum

enum Hand{
	GU = 0,
	CHOKI = 1,
	PA = 2
}

enum Direction{
	UP = 0,
	LEFT = 1,
	DOWN = 2,
	RIGHT = 3
}

enum Player{
	HOST,
	JOIN
}

enum Action{
	ATTACK = 0,
	SKILL = 1
}

## ゲームのフェーズ
enum Phase{
	SELECT_ACTION,
}

enum SelectMode{
	ACTION,
	HAND,
	DIRECTION
}

## じゃんけんの結果
enum JankenResult{
	HOST_WIN,
	JOIN_WIN,
	DRAW
}

enum Winner{
	HOST,
	JOIN,
	DRAW
}
