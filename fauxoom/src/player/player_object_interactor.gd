extends RayCast
class_name PlayerObjectInteractor

func get_is_colliding() -> bool:
	return is_colliding() && Interactions.is_collider_usable(get_collider())

func use_target() -> bool:
	if is_colliding():
		return Interactions.use_collider(get_collider(), self)
	return false

func _process(_delta:float):
	pass
