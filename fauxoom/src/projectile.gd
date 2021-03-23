extends Spatial

const MAX_SPEED:float = 15.0
var _ttl:float = 10
var _time:float = 10

var _velocity:Vector3 = Vector3()

var _ignoreBody = []

func _move_as_ray_2(_delta:float) -> void:
	var t:Transform = global_transform
	t.origin += (_velocity * _delta)
	global_transform = t

func _move_as_ray(_delta:float) -> void:

	var t:Transform = global_transform
	var origin:Vector3 = t.origin
	look_at(origin + _velocity, t.basis.y)

	var speed:float = _velocity.length()
	if speed == 0:
		return
	var hit = ZqfUtils.quick_hitscan3D(self, speed * _delta, _ignoreBody, -1)
	if hit:
		# do damage
		queue_free()
		return
	t.origin = origin + (_velocity * _delta)
	global_transform = t

func _process(_delta:float) -> void:
	_time -= _delta
	if _time <= 0:
		queue_free()
		return
	_move_as_ray(_delta)

func launch(origin:Vector3, _forward:Vector3, ignoreBody:PhysicsBody) -> void:
	_time = _ttl
	var t:Transform = global_transform
	t.origin = origin
	global_transform = t
	_velocity = _forward * MAX_SPEED
	_ignoreBody = [ ignoreBody ]
