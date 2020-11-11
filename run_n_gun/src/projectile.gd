extends Area2D

var _speed: float = 1000.0
var _timeToLive:float = 2.0
var _velocity = Vector2()
var _dead:bool = false

func launch(pos:Vector2, radians:float):
	_dead = false
	position = pos
	_velocity.x = cos(radians) * _speed
	_velocity.y = sin(radians) * _speed
	pass

func _physics_process(delta):
	if _dead:
		return
	_timeToLive -= delta
	if (_timeToLive <= 0):
		_dead = true
		queue_free()
		return
	position += _velocity * delta
