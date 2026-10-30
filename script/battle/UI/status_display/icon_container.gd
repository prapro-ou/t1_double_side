extends HBoxContainer

enum IconKind{
	GUARD_DOWN,
	GUARD_UP,
	COUNTER,
	DUAL_ATTACK,
	DUAL_BLOCK
}

@onready var icon_node:Dictionary[IconKind,TextureRect] = {
	IconKind.GUARD_DOWN:$GuardDown,
	IconKind.GUARD_UP:$GuardUp,
	IconKind.COUNTER:$Counter,
	IconKind.DUAL_ATTACK:$DualAttack,
	IconKind.DUAL_BLOCK:$DualBlock
}

func set_icon(kind:IconKind,val:bool) -> void:
	icon_node[kind].visible = val;
