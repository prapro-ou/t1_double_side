extends Node2D

@onready var player_label_node:Label = $CanvasLayer/Control/PlayerLabel
@onready var opponent_label_node:Label = $CanvasLayer/Control/OpponentLabel

enum Hand{
	One,
	Two,
	Three
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_label_node.text = generate_player_text("")
	opponent_label_node.text = generate_opponent_text("")

func generate_player_text(hand:String) -> String:
	return "あなたが出した手:" + hand;

func generate_opponent_text(hand:String) -> String:
	return "相手が出した手:" + hand

@rpc("any_peer","call_remote","reliable")
func send_hand(hand:Hand):
	opponent_label_node.text = generate_opponent_text(hand_to_text(hand))

func select_hand(hand:Hand) -> void:
	player_label_node.text = generate_player_text(hand_to_text(hand))
	send_hand.rpc(hand)

func hand_to_text(hand:Hand)->String:
	match hand:
		Hand.One:return "1"
		Hand.Two:return "2"
		Hand.Three:return "3"
		_:return ""


func _on_one_button_pressed() -> void:
	select_hand(Hand.One)


func _on_two_button_pressed() -> void:
	select_hand(Hand.Two)


func _on_three_button_pressed() -> void:
	select_hand(Hand.Three)
