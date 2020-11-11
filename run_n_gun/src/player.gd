extends KinematicBody2D

const RUN_SPEED = 200.0
const REFIRE_TIME = 0.1
var _velocity: Vector2 = Vector2()
var _attackTick: float = 0

func _update_attack(_delta:float):
	if (_attackTick > 0):
		_attackTick -= _delta
		return
	if Input.is_action_pressed("attack_1"):
		_attackTick = REFIRE_TIME
		var prj = Game.get_free_player_projectile()
		var mPos = Game.cursorPos
		var radians = mPos.angle_to_point(position)
		radians += rand_range(-0.1, 0.1)
		prj.launch(position, radians)

func _get_input_move():
	var dir = Vector2()
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if Input.is_action_pressed("move_up"):
		dir.y -= 1
	if Input.is_action_pressed("move_down"):
		dir.y += 1
	return dir

func _calc_velocity(_curVel: Vector2, _inputDir: Vector2):
	var result = Vector2()
	if _inputDir.length() == 0:
		return result
	var radians: float = atan2(_inputDir.y, _inputDir.x)
	result.x = cos(radians) * RUN_SPEED
	result.y = sin(radians) * RUN_SPEED
	return result

func _physics_process(delta):
	var dir = _get_input_move()
	_velocity = _calc_velocity(_velocity, dir)
	move_and_slide(_velocity)
	_update_attack(delta)
	pass
