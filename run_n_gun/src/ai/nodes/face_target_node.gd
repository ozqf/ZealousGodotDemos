extends AINodeBase

func tick(info:AIInfo) -> int:
	var toTarget:Vector2 = info.targetPosition - info.mob.global_position
	info.moveDir = toTarget.normalized()
	if info.verbose:
		print("Set move toward target")
	return SUCCESS
