extends KinematicBody

export var speed:float = 125.0
var _ttl:float = 10
var _dead:bool = false
var _launched:bool = false

func remove() -> void:
	if _dead:
		return
	_dead = true
	queue_free()

func _physics_process(delta) -> void:
	if !_launched:
		return
	
	_ttl -= delta
	if _ttl <= 0:
		remove()
		return
	var move:Vector3 = (-global_transform.basis.z * speed) * delta
	var hit = move_and_collide(move)
	if hit != null:
		remove()

func launch(pos:Vector3, dir:Vector3, _spinStartDegrees:float = 0, _spinRateDegrees:float = 0) -> void:
	_launched = true
	var t:Transform = Transform.IDENTITY
	t.origin = pos
	global_transform = t
	look_at(pos + dir, Vector3.UP)
