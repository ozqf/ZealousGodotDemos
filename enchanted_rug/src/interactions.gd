class_name Interactions

const TEAM_NONE:int = 0
const TEAM_ENEMY:int = 1
const TEAM_PLAYER:int = 2
const TEAM_NON_COMBATANT:int = 3

static func hit(target, info:HitInfo) -> void:
	if !is_instance_valid(target):
		return
	if target == null:
		return
	if !target.has_method("hit"):
		return
	target.hit(info)

