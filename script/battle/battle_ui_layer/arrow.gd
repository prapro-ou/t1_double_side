class_name SelectArrow

extends Node2D

## 最大まで引いて離したときに発火（選んだ候補のインデックスを渡す）
signal selected(index: int)
## 最大まで伸びている候補が変わるたびに発火（最大の候補が無いときは -1）
signal charge_max_changed(index: int)

## この距離で最長(frame 2)になる
@export var max_dist:float = 300.0
## これ未満は非表示
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

## snap_angles_deg を変換したスナップ候補の単位ベクトル（キャッシュ）
var _targets:Array[Vector2] = [];

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false;


func _input(event: InputEvent) -> void:
	if is_active:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true;
			else:
				is_dragging = false;
				# 最大まで伸ばして離したらシグナルを出す
				var max_frame:int = anim_sprite_node.sprite_frames.get_frame_count("default") - 1;
				if visible and anim_sprite_node.frame == max_frame:
					selected.emit(aim_index);
				visible = false;
				_set_max_index(-1);
		elif event is InputEventMouseMotion and is_dragging:
			# 中央(根元)から現在のマウスへのベクトル
			var dir:Vector2 = get_global_mouse_position() - global_position;
			if dir.length() < min_dist:
				visible = false;
				_set_max_index(-1);
				return
			visible = true;
			# 候補方向の中から向きが一番近いものにスナップ
			aim_index = _pick_snap(dir, _targets);
			aim_dir = _targets[aim_index];
			# 上向きの絵を狙う向きに合わせて回転（絵が上向き基準なので +PI/2 補正）
			rotation = aim_dir.angle() + PI / 2.0;
			var count:int = anim_sprite_node.sprite_frames.get_frame_count("default");
			var t:float = clampf(dir.length() / max_dist, 0.0, 1.0);
			anim_sprite_node.frame = int(round(t * (count - 1)));
			# 最大まで伸びている間だけその候補を通知（そうでなければ -1）
			_set_max_index(aim_index if anim_sprite_node.frame == count - 1 else -1);


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
