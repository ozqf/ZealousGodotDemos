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
onready var _airJumpSprite: Sprite = $air_jump_sprite
onready var _groundedSprite: Sprite = $grounded_sprite

const SPEED_X = 250.0
const JUMP_STRENGTH = 360
const MAX_AIR_JUMPS = 1

var _velocity = Vector2()
var _gravity = Vector2(0, 900)
var _lastMoveDir = Vector2(1, 0)
var _airJumps:int = 1
var _frame:int = 0
var _slipOn:bool = false

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

func _physics_process(_delta):
	_frame += 1
	var pushX = 0.0
	var pushY = 0.0
	_slipOn = Input.is_action_pressed("slip")
	
	if _againstHorizontal() || !_againstVertical():
		if Input.is_action_pressed("ui_left"):
			pushX -= 1.0
		if Input.is_action_pressed("ui_right"):
			pushX += 1.0
		_velocity.x = pushX * SPEED_X
	if _againstVertical():
		if Input.is_action_pressed("ui_up"):
			pushY -= 1.0
		if Input.is_action_pressed("ui_down"):
			pushY += 1.0
		_velocity.y = pushY * SPEED_X
	
	#_airJumpSprite.visible = (_airJumps > 0)
	#_groundedSprite.visible = is_on_floor()
	
	if !_againstHorizontal() && !_againstVertical():
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
			_velocity.x = _jumpDir.x * JUMP_STRENGTH
			_velocity.y = _jumpDir.y * JUMP_STRENGTH
		pass
	else:
		if _airJumps > 0 && Input.is_action_just_pressed("jump"):
			_velocity.y = -JUMP_STRENGTH
			_airJumps -= 1
	_refresh_face_direction()
	_velocity = move_and_slide(_velocity, Vector2.UP)

# events
func on_player_finish(_player):
	#self.queue_free()
	set_process(false)
	visible = false
