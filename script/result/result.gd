extends Node2D

@onready var result_en = $CanvasLayer/Control/Result_English
@onready var result_jp = $CanvasLayer/Control/Result_Japanese
@onready var re_match = $CanvasLayer/Control/Re_match
@onready var rematch_status = $CanvasLayer/Control/Rematch_Status

enum Result{
	WIN,
	LOSE,
	DRAW
}

func _ready() -> void:
	GameSession.rematch_requested.connect(_on_rematch_requested)
	rematch_status.text = ""

	var win:Result

	if GameSession.battle_winner == BattleEnum.Winner.DRAW:
		win = Result.DRAW
	elif GameSession.battle_winner == GameSession.get_self_player():
		win = Result.WIN
	else:
		win = Result.LOSE
	
	set_result(win)

func set_result(win: Result) -> void:
	if win == Result.WIN:
		result_en.text = "You Win!"
		result_jp.text = "あなたの勝ちです"
	elif win == Result.LOSE:
		result_en.text = "You Lose!"
		result_jp.text = "あなたの負けです"
	elif win == Result.DRAW:
		result_en.text = "DRAW!"
		result_jp.text = "引き分けです"
	else:
		result_en.text = "ERROR!"
		result_jp.text = "エラー"

## もう1戦を希望する。両者がそろうとGameSessionがキャラ選択へ進める
func _on_re_match_pressed() -> void:
	# ホストへ届く前でも押し直せないようにここで無効化する
	re_match.disabled = true
	GameSession.request_rematch()
	_update_rematch_status()

## 自分か相手がもう1戦を希望したとき
func _on_rematch_requested(_player: BattleEnum.Player) -> void:
	_update_rematch_status()

func _update_rematch_status() -> void:
	# 自分の希望はホストに届くまで反映されないので、ボタンの状態で判定する
	if re_match.disabled:
		rematch_status.text = "相手を待っています..."
	elif GameSession.is_rematch_requested(GameSession.get_opponent_player()):
		rematch_status.text = "相手はもう一戦を希望しています"
	else:
		rematch_status.text = ""

func _on_go_title_pressed() -> void:
	SceneManager.change_scene("title")
