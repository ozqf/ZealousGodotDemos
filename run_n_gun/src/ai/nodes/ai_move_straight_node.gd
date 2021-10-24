extends AINodeBase

func tick(info:AIInfo) -> int:
	if info.activeNode != self:
		if info.verbose:
			print(name + " Start move straight")
		info.activeNode = self
		info.time = 1
	if info.time <= 0:
		if info.verbose:
			print(name + " End move straight")
		info.activeNode = null
		return SUCCESS
	else:
		info.time -= info.delta
		var velocity:Vector2 = info.moveDir * 100
		info.mob.move_and_slide(velocity)
		return RUNNING
