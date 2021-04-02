extends RayCast
class_name PlayerObjectInteractor

func get_is_colliding() -> bool:
	return is_colliding()

func use_target() -> void:
	if is_colliding():
		get_collider().use()

func _process(_delta:float):
	pass
