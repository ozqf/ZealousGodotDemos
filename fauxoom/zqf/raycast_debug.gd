extends Spatial

func _process(_delta:float) -> void:
	if !get_parent() is RayCast:
		return
	var raycast:RayCast = get_parent() as RayCast
	visible = raycast.is_colliding()
