extends Node2D

## 最大まで引いて離したときに発火（引いた4方向の単位ベクトルを渡す）
signal fired(direction: Vector2)

@onready var anim_sprite_node:AnimatedSprite2D = $AnimatedSprite2D

## この距離で最長(frame 2)になる
@export var max_dist:float = 300.0  
## これ未満は非表示
@export var min_dist:float = 20.0    

## 操作を受け付けているか
var is_active:bool = true

## ドラッグ中か
var is_dragging:bool = false;

## 現在狙っている4方向の単位ベクトル
var aim_dir:Vector2 = Vector2.ZERO;

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
					fired.emit(aim_dir);
				visible = false;
		elif event is InputEventMouseMotion and is_dragging:
			# 中央(根元)から現在のマウスへのベクトル
			var dir:Vector2 = get_global_mouse_position() - global_position;
			if dir.length() < min_dist:
				visible = false;
				return
			visible = true;
			# 向きを上下左右の4方向にスナップ（上向き絵の補正込み）
			var snapped:float = round(dir.angle() / (PI / 2.0) )  * (PI / 2.0);
			rotation = snapped + PI / 2.0;
			aim_dir = Vector2.from_angle(snapped).round();  # 4方向の単位ベクトル
			var count:int = anim_sprite_node.sprite_frames.get_frame_count("default");
			var t:float = clampf(dir.length() / max_dist, 0.0, 1.0);
			anim_sprite_node.frame = int(round(t * (count - 1)));  # 長さ = フレーム
