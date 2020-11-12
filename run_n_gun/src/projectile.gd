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

func _kill_self():
	if _dead:
		return
	_dead = true
	queue_free()

func _physics_process(delta):
	if _dead:
		return
	_timeToLive -= delta
	if (_timeToLive <= 0):
		_kill_self()
		return
	position += _velocity * delta


func _on_player_projectile_body_entered(body):
	var victim:Life = body.get_node_or_null("life")
	if victim != null:
		victim.take_hit(10)
	_kill_self()
