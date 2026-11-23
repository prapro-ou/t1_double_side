class_name SelectArrow

extends Node2D

## 最大まで引いて離したときに発火（選んだ候補のインデックスを渡す）
signal selected(index: int)
## 最大まで伸びている候補が変わるたびに発火（最大の候補が無いときは -1）
signal charge_max_changed(index: int)

## 引っ張り具合が変わった時に発火（0 = 伸びていない, 大きいほど長い。値は frame と同じ）
signal change_dragged_level(level:int)

## 伸びていないとき(玉の絵)のフレーム。frame 1 以降が伸びている絵（短い順）
const NOT_STRETCHED_FRAME:int = 0

## この距離で最長(最後のフレーム)になる
@export var max_dist:float = 300.0
## これ未満は伸びていない絵(frame 0)のまま
@export var min_dist:float = 20.0
## スナップ先の候補角度（度, 矢印の向き基準）。0=上, 90=右, 180=下, 270(=-90)=左（時計回り）
@export var snap_angles_deg:Array[float] = []:
	set(value):
		snap_angles_deg = value;
		_rebuild_targets();
## 操作を受け付けているか
@export var is_active:bool = false


@onready var anim_sprite_node:AnimatedSprite2D = $AnimatedSprite2D

## ドラッグ中か
var is_dragging:bool = false;

## 現在狙っている候補の単位ベクトル
var aim_dir:Vector2 = Vector2.ZERO;

## 現在狙っている候補のインデックス（未選択は -1）
var aim_index:int = -1;

## 現在最大まで伸びている候補のインデックス（無ければ -1）
var _max_index:int = -1;

## 前回の更新時の矢印の長さ(frame)
var _old_arrow_length:int = NOT_STRETCHED_FRAME;

## snap_angles_deg を変換したスナップ候補の単位ベクトル（キャッシュ）
var _targets:Array[Vector2] = [];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 他のノードが準備できていないので、ここではシグナルを出さずに絵だけ戻す
	rotation = 0.0;
	anim_sprite_node.frame = NOT_STRETCHED_FRAME;


func _input(event: InputEvent) -> void:
	if is_active:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true;
			else:
				is_dragging = false;
				# 最大まで伸ばして離したらシグナルを出す
				if anim_sprite_node.frame == _get_max_frame():
					selected.emit(aim_index);
				_reset_arrow();
		elif event is InputEventMouseMotion and is_dragging:
			# 中央(根元)から現在のマウスへのベクトル
			var dir:Vector2 = get_global_mouse_position() - global_position;
			if dir.length() < min_dist:
				_reset_arrow();
				return
			# 候補方向の中から向きが一番近いものにスナップ
			aim_index = _pick_snap(dir, _targets);
			aim_dir = _targets[aim_index];
			# 上向きの絵を狙う向きに合わせて回転（絵が上向き基準なので +PI/2 補正）
			rotation = aim_dir.angle() + PI / 2.0;
			# 伸びている絵(frame 1 〜 最後)の中から距離に応じて選ぶ
			var max_frame:int = _get_max_frame();
			var t:float = clampf(dir.length() / max_dist, 0.0, 1.0);
			var current_arrow_length:int = NOT_STRETCHED_FRAME + 1 + int(round(t * (max_frame - NOT_STRETCHED_FRAME - 1)));
			_set_arrow_length(current_arrow_length)

			# 最大まで伸びている間だけその候補を通知（そうでなければ -1）
			_set_max_index(aim_index if anim_sprite_node.frame == max_frame else -1);

## 最長の絵のフレーム番号
func _get_max_frame() -> int:
	return anim_sprite_node.sprite_frames.get_frame_count("default") - 1;

## 伸びていない状態(玉の絵)に戻す
func _reset_arrow() -> void:
	# 玉の絵は向きを持たないので回転も戻す
	rotation = 0.0;
	_set_max_index(-1);
	_set_arrow_length(NOT_STRETCHED_FRAME);

## 長さが変わったときだけ絵を更新して通知する
func _set_arrow_length(length:int) -> void:
	if length == _old_arrow_length:
		return
	_old_arrow_length = length
	anim_sprite_node.frame = length
	change_dragged_level.emit(length)

## 最大まで伸びている候補が変わったときだけ charge_max_changed を発火
func _set_max_index(i: int) -> void:
	if i != _max_index:
		_max_index = i;
		charge_max_changed.emit(i);


## snap_angles_deg からスナップ候補の単位ベクトルを再計算してキャッシュする
func _rebuild_targets() -> void:
	_targets.clear();
	for a in snap_angles_deg:
		# 角度は上向き基準・時計回り。ワールド角(0=右)へは -90° 補正
		_targets.append(Vector2.from_angle(deg_to_rad(a) - PI / 2.0));


## targets の中で dir に最も向きが近い候補のインデックスを返す
func _pick_snap(dir: Vector2, targets: Array[Vector2]) -> int:
	var d:Vector2 = dir.normalized();
	var best_i:int = 0;
	var best_dot:float = -INF;
	for i in targets.size():
		var dot:float = d.dot(targets[i].normalized());
		if dot > best_dot:
			best_dot = dot;
			best_i = i;
	return best_i;
