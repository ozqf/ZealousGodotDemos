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

func _againstFloor():
	return _floorLeft.on() || _floorCentre.on() || _floorRight.on()

func _againstTop():
	return _topLeft.on() || _topCentre.on() || _topRight.on()

func _againstLeft():
	return _leftTop.on() || _leftCentre.on() || _leftBottom.on()

func _againstRight():
	return _rightTop.on() || _rightCentre.on() || _rightBottom.on()

func _againstHorizontal():
	return _againstFloor() || _againstTop()

func _againstVertical():
	return _againstLeft() || _againstRight()

func _physics_process(_delta):
	_frame += 1
	var pushX = 0.0
	var pushY = 0.0
	
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
	
	_airJumpSprite.visible = (_airJumps > 0)
	_groundedSprite.visible = is_on_floor()
	
	# IF USING is_on_floor()
	# gravity must always be applied even when on ground
	# otherwise is_on_floor will fail if move_and_slide
	# has no y component into the floor!
	if !_againstHorizontal() && !_againstVertical():
		_velocity.y += _gravity.y * _delta
	else:
		_airJumps = MAX_AIR_JUMPS
	
	# if is_on_floor():
	if _againstFloor():
		_airJumps = MAX_AIR_JUMPS
		if Input.is_action_just_pressed("jump"):
			# print(str(_frame) + " Jump")
			_velocity.y = -JUMP_STRENGTH
			#_velocity.y = -500
		pass
	else:
		if _airJumps > 0 && Input.is_action_just_pressed("jump"):
			# print(str(_frame) + " Air jump")
			_velocity.y = -JUMP_STRENGTH
			_airJumps -= 1
	
	# update default face direction
	if _velocity.x > 0:
		_lastMoveDir = Vector2(1, 0)
		_melee.set_last_move_dir(Vector2(1, 0))
	elif _velocity.x < 0:
		_lastMoveDir = Vector2(-1, 0)
		_melee.set_last_move_dir(Vector2(-1, 0))
	
	_velocity = move_and_slide(_velocity, Vector2.UP)
