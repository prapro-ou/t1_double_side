class_name CharaData
extends Resource

@export var id: StringName        # 通信・セーブ用の安定ID（"attacker" 等）
@export var sprite_frames:SpriteFrames
@export var display_name: String
@export var max_hp: int
@export var max_mp:int

@export var attack: int

@export var skill_name:String
@export_multiline() var skill_discription:String

@export_multiline() var catchprase:String
@export_multiline() var catchprase_description:String
