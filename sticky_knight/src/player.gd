extends KinematicBody2D

onready var _floorLeft:WorldSensor = $sensors/floor_left
onready var _floorCentre:WorldSensor = $sensors/floor_centre
onready var _floorRight:WorldSensor = $sensors/floor_right

onready var _topLeft:WorldSensor = $sensors/top_left
onready var _topCentre:WorldSensor = $sensors/top_centre
onready var _topRight:WorldSensor = $sensors/top_right

onready var _leftTop:WorldSensor = $sensors/left_top
onready var _leftCentre:WorldSensor = $sensors/left_centre
onready var _leftBottom:WorldSensor = $sensors/left_bottom

onready var _rightTop:WorldSensor = $sensors/right_top
onready var _rightCentre:WorldSensor = $sensors/right_centre
onready var _rightBottom:WorldSensor = $sensors/right_bottom

onready var _melee: PlayerMelee = $melee
onready var _sprite:Sprite = $sprites/body
onready var _airJumpSprite:Sprite = $air_jump_sprite
onready var _groundedSprite:Sprite = $grounded_sprite

const RUN_SPEED = 220.0
const JUMP_STRENGTH = 365
const AIR_JUMP_STRENGTH = 365
const MAX_AIR_JUMPS = 1
const MAX_FALL_SPEED = 500
const GROUND_FRICTION = 0.8
const AIR_FRICTION = 0.99
const GROUND_SECONDS_TO_RUN_SPEED = 0.05
#const GROUND_SECONDS_TO_STOP = 0.1

var _pushAccumulator:Vector2 = Vector2()

var _velocity:Vector2 = Vector2()
var _gravity:Vector2 = Vector2(0, 900)
var _lastMoveDir:Vector2 = Vector2(1, 0)
var _airJumps:int = 1
var _frame:int = 0
var _slipOn:bool = false
var _startPos: Vector2 = Vector2()

func _ready():
	_melee.player = self

func set_start_position(pos:Vector2):
	_startPos = pos

func _againstFloor():
	return _floorLeft.on() || _floorCentre.on() || _floorRight.on()

func _againstTop():
	if _slipOn:
		return false
	return _topLeft.on() || _topCentre.on() || _topRight.on()

func _againstLeft():
	if _slipOn:
		return false
	return _leftTop.on() || _leftCentre.on() || _leftBottom.on()

func _againstRight():
	if _slipOn:
		return false
	return _rightTop.on() || _rightCentre.on() || _rightBottom.on()

func _againstHorizontal():
	return _againstFloor() || _againstTop()

func _againstVertical():
	return _againstLeft() || _againstRight()

func _refresh_face_direction():
	# update for default melee attack direction
	if _velocity.x > 0:
		_lastMoveDir.x = 1
	elif _velocity.x < 0:
		_lastMoveDir.x = -1
	if _velocity.y > 0:
		_lastMoveDir.y = 1
	elif _velocity.y < 0:
		_lastMoveDir.y = -1
	if !_againstVertical():
		_melee.set_last_move_dir(Vector2(_lastMoveDir.x, 0))
	else:
		_melee.set_last_move_dir(Vector2(0, _lastMoveDir.y))
	
	# set sprite orientation
	if !_againstVertical():
		_sprite.rotation_degrees = 0
		if _againstTop():
			_sprite.flip_v = true
		else:
			_sprite.flip_v = false
		if _lastMoveDir.x < 0:
			_sprite.flip_h = true
		else:
			_sprite.flip_h = false
	else:
		_sprite.rotation_degrees = 90
		if _againstRight():
			_sprite.flip_v = true
		else:
			_sprite.flip_v = false
		if _lastMoveDir.y < 0:
			_sprite.flip_h = true
		else:
			_sprite.flip_h = false

func _calc_ground_jump_dir():
	var _dir:Vector2 = Vector2()
	if _againstFloor():
		_dir += Vector2(0, -1)
	if _againstTop():
		_dir += Vector2(0, 1)
	if _againstLeft():
		_dir += Vector2(0.5, -0.5)
	if _againstRight():
		_dir += Vector2(-0.5, -0.5)
	_dir = _dir.normalized()
	if _dir.length() == 0:
		return Vector2(0, -1)
	return _dir

func _calc_push_ratio(curSpeed:float, maxSpeed:float):
	var r = 1.0 - (curSpeed / maxSpeed)
	if r < 0: r = 0
	if r > 1: r = 1
	return r

func _physics_process(_delta):
	_frame += 1
	var pushX = 0.0
	var pushY = 0.0
	_slipOn = Input.is_action_pressed("slip")
	
	if _againstHorizontal() || !_againstVertical():
		if Input.is_action_pressed("ui_left"):
			pushX -= 1.0
			var push:float = _calc_push_ratio(_velocity.x, -RUN_SPEED)
			var accel:float = -(RUN_SPEED / GROUND_SECONDS_TO_RUN_SPEED)
			_velocity.x += (accel * push) * _delta
			#print("PushMul " + str(push) + " vel " + str(_velocity.x))
		if Input.is_action_pressed("ui_right"):
			pushX += 1.0
			var push:float = _calc_push_ratio(_velocity.x, RUN_SPEED)
			var accel:float = RUN_SPEED / GROUND_SECONDS_TO_RUN_SPEED
			_velocity.x += (accel * push) * _delta
			#print("PushMul " + str(push) + " vel " + str(_velocity.x))
		#_velocity.x = pushX * RUN_SPEED
		# apply friction if on floor and not pushing
		if pushX == 0:
			if _againstHorizontal():
				_velocity.x *= GROUND_FRICTION
			else:
				_velocity.x *= AIR_FRICTION
	if _againstVertical():
		if Input.is_action_pressed("ui_up"):
			pushY -= 1.0
			var push:float = _calc_push_ratio(_velocity.y, -RUN_SPEED)
			var accel:float = -(RUN_SPEED / GROUND_SECONDS_TO_RUN_SPEED)
			_velocity.y += (accel * push) * _delta
		if Input.is_action_pressed("ui_down"):
			pushY += 1.0
			var push:float = _calc_push_ratio(_velocity.y, RUN_SPEED)
			var accel:float = RUN_SPEED / GROUND_SECONDS_TO_RUN_SPEED
			_velocity.y += (accel * push) * _delta
		#_velocity.y = pushY * RUN_SPEED
		if _againstVertical() && pushY == 0:
			_velocity.y *= GROUND_FRICTION
	
	if !_againstHorizontal() && !_againstVertical():
		if _velocity.y < MAX_FALL_SPEED:
			_velocity.y += _gravity.y * _delta
	else:
		_airJumps = MAX_AIR_JUMPS
	
	var canGroundJump = _againstHorizontal() || _againstVertical()
	
	if canGroundJump:
		_airJumps = MAX_AIR_JUMPS
		if Input.is_action_just_pressed("jump"):
			var _jumpDir:Vector2 = _calc_ground_jump_dir()
			if _jumpDir.x == 0 && _jumpDir.y == 1:
				_jumpDir.y = 0.25
			_velocity.x += _jumpDir.x * JUMP_STRENGTH
			_velocity.y += _jumpDir.y * JUMP_STRENGTH
		pass
	else:
		if _airJumps > 0 && _velocity.y > -AIR_JUMP_STRENGTH && Input.is_action_just_pressed("jump"):
			_velocity.y = -AIR_JUMP_STRENGTH
			_airJumps -= 1
	_refresh_face_direction()
	_velocity = move_and_slide(_velocity, Vector2.UP)

############################################
# events
############################################
func on_attack(dir:Vector2):
	if _velocity.y > -50 && !_againstHorizontal() && !_againstVertical():
		_velocity.y = -50

func on_player_finish(_player):
	#self.queue_free()
	set_process(false)
	visible = false

func kill():
	#get_tree().call_group("game", "on_player_died", self)
	#queue_free()
	self.position = _startPos
	_velocity = Vector2()

func touch_spring(push:Vector2):
	print("Push " + str(push))
	_velocity = push

func touch_spike(_spike):
	var spikePos:Vector2 = _spike.global_position
	var selfPos:Vector2 = global_position
	var radians:float = selfPos.angle_to_point(spikePos)
	_velocity.x = cos(radians) * 600
	_velocity.y = sin(radians) * 600
	print("Touch Spike")
