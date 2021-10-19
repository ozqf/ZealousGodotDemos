extends Spatial

func _process(_delta:float) -> void:
	var canSeeGround:bool = false
	if get_parent() is RayCast:
		var raycast:RayCast = get_parent() as RayCast
		canSeeGround  = raycast.is_colliding()
	if !canSeeGround:
		visible = false
		return
	var selfPos:Vector3 = global_transform.origin
	var point:Vector3 = AI.find_closest_navmesh_point(selfPos)
	if selfPos.distance_to(point) < 0.5:
		visible = true
	else:
		visible = false
