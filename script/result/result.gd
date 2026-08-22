extends Node2D

@onready var chara_image_node:TextureRect = $CanvasLayer/Control/CharaImage

@onready var result_en = $CanvasLayer/Control/Result_English
@onready var result_jp = $CanvasLayer/Control/Result_Japanese
@onready var re_match = $CanvasLayer/Control/Re_match
@onready var go_title = $CanvasLayer/Control/Go_title

@onready var talk_node:Label = $CanvasLayer/Control/TalkBack/TalkLabel

@onready var rematch_back:Panel = $CanvasLayer/Control/RematchBack
@onready var rematch_status = $CanvasLayer/Control/RematchBack/Rematch_Status

var image_list:Dictionary[StringName,Texture2D] = {
	&"fire_man":preload("res://assets/img/chara/fire_man/fire_man.png"),
	&"guard_man":preload("res://assets/img/chara/guard_man/guard_man.png"),
	&"logic_woman":preload("res://assets/img/chara/logic_woman/logic_woman.png")
}

## タイトルに戻ることを選んだかどうか。再戦の状況表示と混ざらないようにする
var _leaving:bool = false

enum Result{
	WIN,
	LOSE,
	DRAW
}

func _ready() -> void:
	GameSession.rematch_requested.connect(_on_rematch_requested)
	rematch_status.text = ""
	
	var win:Result
	# 映すキャラ。引き分けのときは勝者がいないので自分のキャラにする
	var chara_player:BattleEnum.Player

	if GameSession.battle_winner == BattleEnum.Winner.DRAW:
		win = Result.DRAW
		chara_player = GameSession.get_self_player()
	elif GameSession.battle_winner == GameSession.get_self_player():
		win = Result.WIN
		chara_player = GameSession.get_self_player()
	else:
		win = Result.LOSE
		chara_player = GameSession.get_opponent_player()
		
	var chara:CharaData = GameSession.get_chara_data(chara_player)
		
	show_chara(chara)
	set_talk(chara)
	set_result(win)

## 指定されたキャラの画像を映す。未選択・未登録のキャラなら何も映さない
func show_chara(chara:CharaData) -> void:
	if chara == null or not image_list.has(chara.id):
		chara_image_node.texture = null
		return
	chara_image_node.texture = image_list[chara.id]

func set_talk(chara:CharaData) -> void:
	talk_node.text = chara.winner_text

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
	DecidedSePlayer.play()
	# ホストへ届く前でも押し直せないようにここで無効化する
	re_match.disabled = true
	GameSession.request_rematch()
	_update_rematch_status()

## 自分か相手がもう1戦を希望したとき
func _on_rematch_requested(_player: BattleEnum.Player) -> void:
	_update_rematch_status()

func _update_rematch_status() -> void:
	if _leaving:
		return
	# 自分の希望はホストに届くまで反映されないので、ボタンの状態で判定する
	if re_match.disabled:
		rematch_back.show()
		rematch_status.text = "相手を待っています..."
	elif GameSession.is_rematch_requested(GameSession.get_opponent_player()):
		rematch_back.show()
		rematch_status.text = "相手はもう一戦を希望しています"
	else:
		rematch_back.hide()
		rematch_status.text = ""

## タイトルに戻る。相手には退出したことが伝わる
func _on_go_title_pressed() -> void:
	# 切断するまでの間に押し直せないようにする
	_leaving = true
	re_match.disabled = true
	go_title.disabled = true
	rematch_back.show()
	rematch_status.text = "タイトルに戻ります..."
	
	DecidedSePlayer.play()

	GameSession.leave_to_title()
