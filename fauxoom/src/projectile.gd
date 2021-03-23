extends Spatial

const MAX_SPEED:float = 20.0

var _velocity:Vector3 = Vector3()

func _move_as_ray(_delta:float) -> void:

	var t:Transform = global_transform
	var origin:Vector3 = t.origin
	look_at(origin + _velocity, t.basis.y)

	var speed:float = _velocity.length()
	if speed == 0:
		return
	var hit = ZqfUtils.quick_hitscan3D(self, speed * _delta, [], 0)
	if hit:
		# do damage
		queue_free()
		return
	t.origin = origin + (_velocity * _delta)
	global_transform = t

func _process(_delta:float) -> void:
	_move_as_ray(_delta)

func launch(_forward:Vector3) -> void:
	_velocity = _forward * MAX_SPEED
