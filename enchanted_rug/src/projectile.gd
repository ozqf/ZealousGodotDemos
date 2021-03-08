extends KinematicBody

var _speed:float = 75.0
var _ttl:float = 10

func _physics_process(delta) -> void:
	_ttl -= delta
	if _ttl <= 0:
		queue_free()
		return
	var move:Vector3 = (-global_transform.basis.z * _speed) * delta
	move_and_collide(move)

func launch(pos:Vector3, dir:Vector3) -> void:
	var t:Transform = Transform.IDENTITY
	t.origin = pos
	global_transform = t
	look_at(pos + dir, Vector3.UP)
