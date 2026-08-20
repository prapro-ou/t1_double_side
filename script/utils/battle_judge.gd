class_name BattleJudge

## 各手が勝てる相手の手
const BEATS:Dictionary[BattleEnum.Hand,BattleEnum.Hand] = {
	BattleEnum.Hand.GU: BattleEnum.Hand.CHOKI,
	BattleEnum.Hand.CHOKI: BattleEnum.Hand.PA,
	BattleEnum.Hand.PA: BattleEnum.Hand.GU,
}

## じゃんけんの勝敗を判定する
static func judge_janken(host:BattleEnum.Hand,join:BattleEnum.Hand) -> BattleEnum.JankenResult:
	if host == join:
		return BattleEnum.JankenResult.DRAW
	if BEATS[host] == join:
		return BattleEnum.JankenResult.HOST_WIN
	return BattleEnum.JankenResult.JOIN_WIN

## あっち向いてホイの成否を判定する
## どれか1つでも一致すればガード成功
static func judge_hoi(pointed:BattleEnum.Direction,faced:Array[BattleEnum.Direction]) -> bool:
	return faced.has(pointed)


static func is_janken_winner(result:BattleEnum.JankenResult,player:BattleEnum.Player) -> bool:
	match result:
		BattleEnum.JankenResult.HOST_WIN:
			return player == BattleEnum.Player.HOST
		BattleEnum.JankenResult.JOIN_WIN:
			return player == BattleEnum.Player.JOIN
		_:
			return false
