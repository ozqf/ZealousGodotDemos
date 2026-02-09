class_name Interactions

static func try_hurt(atkInfo:AttackInfo, victim:Node) -> int:
	if atkInfo == null:
		return 0
	if victim == null:
		return 0
	if !victim.has_method("hurt"):
		return 0
	return victim.hurt(atkInfo)
