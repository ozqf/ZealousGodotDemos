class_name Interactions

const LAYER_WORLD:int = (1 << 0)
const LAYER_ACTOR:int = (1 << 1)
const LAYER_DAMAGE:int = (1 << 2)
const LAYER_HURT_BOX:int = (1 << 3)
const LAYER_PLAYER_BARRIER:int = (1 << 4)

static func get_los_mask() -> int:
	return LAYER_WORLD

static func get_hitscan_mask() -> int:
	return LAYER_WORLD | LAYER_HURT_BOX

static func try_hurt(atkInfo:AttackInfo, victim:Node) -> int:
	if atkInfo == null:
		return 0
	if victim == null:
		return 0
	if !victim.has_method("hurt"):
		return 0
	return victim.hurt(atkInfo)
