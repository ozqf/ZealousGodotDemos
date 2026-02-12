class_name Interactions

const HIT_RESPONSE_WHIFF:int = 0 # you hit, but did no damage
const HIT_SOLID:int = -1 # you hit but did no damage and never will
const HIT_IGNORE:int = -2 # pretend this never happened and move on

const LAYER_WORLD:int = (1 << 0)
const LAYER_ACTOR:int = (1 << 1)
const LAYER_DAMAGE:int = (1 << 2)
const LAYER_HURT_BOX:int = (1 << 3)
const LAYER_PLAYER_BARRIER:int = (1 << 4)
const LAYER_SENSOR:int = (1 << 5)
const LAYER_PLAYER_AVATAR:int = (1 << 6)

static func get_los_mask() -> int:
	return LAYER_WORLD

static func get_hitscan_mask() -> int:
	return LAYER_WORLD | LAYER_HURT_BOX

static func try_hurt(atkInfo:AttackInfo, victim:Node) -> int:
	if atkInfo == null:
		return HIT_IGNORE
	if victim == null:
		return HIT_IGNORE
	if !victim.has_method("hurt"):
		return HIT_SOLID
	return victim.hurt(atkInfo)
