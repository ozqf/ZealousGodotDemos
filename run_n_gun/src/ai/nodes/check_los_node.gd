extends AINodeBase

func tick(info:AIInfo) -> int:
	var spaceRId = info.mob.get_world_2d().space
	var space:Physics2DDirectSpaceState = Physics2DServer.space_get_direct_state(spaceRId)
	var mask:int = (1 << 0)
	var hit:Dictionary = space.intersect_ray(info.selfPosition, info.targetPosition, [], mask)
	if hit:
		if info.verbose:
			print("Cannot see player")
		return FAILURE
	if info.verbose:
		print("Can see player")
	call_first_child(info)
	return SUCCESS
