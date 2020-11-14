extends KinematicBody2D

const SPEED_X = 250.0

var _velocity = Vector2()
var _gravity = Vector2(0, 900)

func _physics_process(_delta):
	var pushX = 0.0
	if Input.is_action_pressed("ui_left"):
		pushX -= 1.0
	if Input.is_action_pressed("ui_right"):
		pushX += 1.0
	_velocity.x = pushX * SPEED_X
	
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			_velocity.y = -350
		pass
	else:
		_velocity.y += _gravity.y * _delta
	
	_velocity = move_and_slide(_velocity, Vector2.UP)
	
