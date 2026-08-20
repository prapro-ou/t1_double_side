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
	SKILL = 1,
	CATCHPHRASE = 2,
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


## フラグ管理周りのenum
#region

## 発動条件が満たされるのを待っているフラグ
enum PendingFlag{
	FIRE_SK_DUAL_ATTACK, # fire_manのスキル
	GUARD_SK_DUAL_BLOCK, # guard_manのスキル
	LOGIC_SK_COUNTER, #logic_womanのスキル
}

## そのターンの終わりに消えるフラグ
enum TurnFlag{
	CATCHPHRASE, #このターン決め台詞を使った
	FIRE_IGNORE_GUARD, #firemanの決め台詞で相手のガードを無視する
	FIRE_DISABLE_GUARD #firemanの決め台詞で自分がガードできない
}

enum PermanenceFlag{
	GUARD_CP_ARMOR, #guard_manの決め台詞が成功
	GUARD_CP_WEEK, #guard_manの決め台詞が失敗
}

#endregion
