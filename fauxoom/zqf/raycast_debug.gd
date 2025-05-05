extends Node3D

var isValid:bool = false

func _process(_delta:float) -> void:
	var canSeeGround:bool = false
	if get_parent() is RayCast3D:
		var raycast:RayCast3D = get_parent() as RayCast3D
		canSeeGround  = raycast.is_colliding()
	if !canSeeGround:
		visible = false
		isValid = false
		return
	var selfPos:Vector3 = global_transform.origin
	var point:Vector3 = AI.find_closest_navmesh_point(selfPos)
	if selfPos.distance_to(point) < 0.5:
		visible = true
		isValid = true
	else:
		visible = false
		isValid = false
