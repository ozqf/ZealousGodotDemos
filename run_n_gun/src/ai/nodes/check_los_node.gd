extends AINodeBase

func tick(info:AIInfo) -> int:
	var spaceRId = info.mob.get_world_2d().space
	var space:PhysicsDirectSpaceState2D = PhysicsServer2D.space_get_direct_state(spaceRId)
	var mask:int = (1 << 0)
	var params:PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()
	params.from = info.selfPosition
	params.to = info.targetPosition
	params.collision_mask = mask
	params.exclude = []
	var hit:Dictionary = space.intersect_ray(params)
	if hit:
		if info.verbose:
			print("Cannot see player")
		return FAILURE
	if info.verbose:
		print("Can see player")
	call_first_child(info)
	return SUCCESS
