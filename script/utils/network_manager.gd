extends Node

signal connected_to_signaling()
signal room_created()              # ホスト：部屋作成成功
signal joined_room(host_name:String)      # クライアント：参加成功
signal peer_joined(id:int,username:String)             # 誰か参加（ロビーの人数表示用）
signal peer_left(id:int,username:String)
signal signaling_error(message:String)    # エラーの出力


const SIGNALING_URL:String = "wss://signaling.kotukoroom.net/ws";
const ICE_SERVERS:Dictionary = { "iceServers": [{ "urls": ["stun:stun.l.google.com:19302"] }] }

var is_host:bool = false;

var ws = WebSocketPeer.new()
var rtc = WebRTCMultiplayerPeer.new()

var connection_list:Dictionary[int,WebRTCPeerConnection] = {}
var pending_action:Dictionary[String, Variant]

## WebSocketを閉じる（送信待ちのpending_actionは破棄しない）
func _close_ws() -> void:
	if ws.get_ready_state() != WebSocketPeer.STATE_CLOSED:
		ws.close()

## シグナリングサーバー(WebSocket)との接続のみを切断する
## WebRTCのP2P接続は維持する（ゲーム開始後はシグナリングサーバーが不要なため）
func _disconnect_signaling() -> void:
	_close_ws()
	pending_action = {}

## WebRTCのP2P接続とシグナリングサーバー(WebSocket)接続をすべて切断する
## pending_actionはクリアしない（接続開始直前のリセットでも使うため）
func _reset_connection() -> void:
	for conn:WebRTCPeerConnection in connection_list.values():
		conn.close()
	connection_list.clear()
	if multiplayer.multiplayer_peer == rtc:
		multiplayer.multiplayer_peer = null
	_close_ws()

## サーバーとの接続をすべて切断し、接続前の状態に戻す（ロビーから戻るとき用）
func leave() -> void:
	_reset_connection()
	pending_action = {}
	is_host = false

## WebSocketでシグナリングサーバーに接続
func _connect_ws() -> void:
	_reset_connection()
	rtc = WebRTCMultiplayerPeer.new()
	ws = WebSocketPeer.new()
	var err:Error = ws.connect_to_url(SIGNALING_URL)
	if err != OK:
		signaling_error.emit("接続に失敗しました")

## sdpの作成、送信
func _on_sdp_created(type:String,sdp:String,peer_id:int):
	connection_list[peer_id].set_local_description(type,sdp)
	var cmd = "Offer" if type == "offer" else "Answer"
	_send({"cmd":cmd,"target_id":peer_id,"sdp":sdp})

## IceCandidateの作成、送信
func _on_ice_created(media: String, index: int, cand_name: String, peer_id: int) -> void:
	_send({ "cmd": "IceCandidate", "target_id": peer_id,"media": media, "index": index, "name": cand_name })

## WebRTCで接続
func _create_connection(peer_id:int) -> WebRTCPeerConnection:
	var conn:WebRTCPeerConnection = WebRTCPeerConnection.new()
	conn.initialize(ICE_SERVERS)
	conn.session_description_created.connect(_on_sdp_created.bind(peer_id))
	conn.ice_candidate_created.connect(_on_ice_created.bind(peer_id))
	rtc.add_peer(conn,peer_id)
	connection_list[peer_id] = conn
	return conn

## WebSocketでサーバーにJSONを送信
func _send(message:Dictionary[String,Variant]) -> void:
	ws.send_text(JSON.stringify(message))

## 受け取ったメッセージの処理
func _handle_message(msg:Dictionary) -> void:
	match msg.get("cmd"):
		"Id": _on_id(int(msg["id"]));
		"HostInfo": joined_room.emit(msg["username"])
		"PeerConnect":_on_peer_connect(int(msg["id"]),msg["username"])
		"PeerDisconnect":_on_peer_disconnect(int(msg["id"]),msg["username"])
		"Offer":_on_offer(int(msg["target_id"]),msg["sdp"])
		"Answer":connection_list[int(msg["target_id"])].set_remote_description("answer",msg["sdp"])
		"IceCandidate":connection_list[int(msg["target_id"])].add_ice_candidate(msg["media"],int(msg["index"]),msg["name"])
		"Error":signaling_error.emit(msg.get("message", "原因不明のエラー"))

## IDメッセージ
func _on_id(id:int) -> void:
	if is_host:
		rtc.create_server()
	else:
		rtc.create_client(id)
	multiplayer.multiplayer_peer = rtc
	if is_host:
		room_created.emit()

## PeerConnectメッセージ
func _on_peer_connect(id:int,username:String):
	var conn:WebRTCPeerConnection = _create_connection(id);
	conn.create_offer()
	peer_joined.emit(id,username)

## PeerDisconnectメッセージ
func _on_peer_disconnect(id:int,username:String):
	if connection_list.has(id):
		connection_list[id].close()
		connection_list.erase(id)
	peer_left.emit(id,username)

## Offerメッセージ
func _on_offer(target_id:int,sdp:String):
	var conn:WebRTCPeerConnection = _create_connection(target_id)
	conn.set_remote_description("offer",sdp)

## ホストとしてサーバーに接続
func host_game(username:String,password:String,max_player:int) -> void:
	is_host = true;
	pending_action =  { "cmd": "Host", "username": username, "password": password, "max_player": max_player }
	_connect_ws()

## Joinとしてサーバーに接続
func join_game(username:String,password:String) -> void:
	is_host = false
	pending_action =  { "cmd": "Join", "username": username, "password": password}
	_connect_ws()

#----------------------------------------------------------------------------------
@rpc("authority", "call_local", "reliable")
func start_game() -> void:
	_disconnect_signaling()
	SceneManager.change_scene("webrtc_test")

## 接続後、pending_actionの内容を送信する
func _process(delta: float) -> void:
	ws.poll()
	var state:WebSocketPeer.State = ws.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if not pending_action.is_empty():
			connected_to_signaling.emit()
			_send(pending_action)
			pending_action = {}
		while ws.get_available_packet_count() > 0:
			var msg = JSON.parse_string(ws.get_packet().get_string_from_utf8())
			if msg != null:
				_handle_message(msg)
	
