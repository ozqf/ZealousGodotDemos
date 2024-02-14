extends Area3D

var subject = null

func get_health_percentage() -> float:
	if subject != null:
		return subject.get_health_percentage()
	return get_parent().get_health_percentage()

func hit(_hitInfo:HitInfo) -> int:
	if subject != null:
		return subject.hit(_hitInfo)
	return get_parent().hit(_hitInfo)

func receive_grab(grabber) -> Node3D:
	if subject != null:
		return subject.receive_grab(grabber)
	return get_parent().receive_grab(grabber)
