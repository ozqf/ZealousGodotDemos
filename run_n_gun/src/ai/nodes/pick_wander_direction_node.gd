extends AINodeBase

func tick(info:AIInfo) -> int:
	var radians = rand_range(0, 360) * Game.DEG2RAD
	info.moveDir.x = cos(radians)
	info.moveDir.y = sin(radians)
	print("Pick wander")
	return SUCCESS
