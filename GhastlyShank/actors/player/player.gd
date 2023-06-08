extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _head:Node3D = $head

@onready var _weaponModel:Node3D = $head/weapon_model

@onready var _rightHighStart:Node3D = $head/right/right_high_start
@onready var _rightHighEnd:Node3D = $head/right/right_high_end

@onready var _rightMidStart:Node3D = $head/right/right_mid_start
@onready var _rightMidEnd:Node3D = $head/right/right_mid_end

@onready var _leftHighStart:Node3D = $head/right/left_high_start
@onready var _leftHighEnd:Node3D = $head/right/left_high_end

@onready var _leftMidStart:Node3D = $head/right/left_mid_start
@onready var _leftMidEnd:Node3D = $head/right/left_mid_end

@onready var _centreChopStart:Node3D = $head/right/centre_chop_start
@onready var _centreChopEnd:Node3D = $head/right/centre_chop_end

@onready var _thrustStart:Node3D = $head/right/thrust_start
@onready var _thrustEnd:Node3D = $head/right/thrust_end


@onready var _rightHand:Node3D = $head/right
@onready var _leftHand:Node3D = $head/left

@onready var _moveDirIcon:Control = $hud/crosshair/move_direction
@onready var _lookDirIcon:Control = $hud/crosshair/look_direction

var _tick:float = 0.0
var _tickMax:float = 0.25
var _swinging:bool = false

var _nextSwingType:int = -1
var _lastSwingType:int = -1

var _a:Transform3D
var _b:Transform3D

var _timeSinceLastMouseDelta:float = 0.0
var _mouseDelta:Vector2 = Vector2()
var _movePushDelta:Vector2 = Vector2()

func _ready() -> void:
	_rightHand.visible = false

###################################################
# Attack
###################################################

func _run_swing(duration:float, start:Transform3D, end:Transform3D):
	_swinging = true
	_tick = 0.0
	_tickMax = duration
	_a = start
	_b = end

func _auto_swing() -> void:
	_lastSwingType = _nextSwingType
	match _nextSwingType:
		0:
			_nextSwingType = 1
#			_swing_right_high()
			_run_swing(0.3, _rightMidStart.transform, _rightMidEnd.transform)
#			_run_swing(0.4, _rightHighStart.transform, _rightHighEnd.transform)
		1:
			_nextSwingType = 0
#			_swing_left_high()
#			_run_swing(0.3, _leftHighStart.transform, _leftHighEnd.transform)
			_run_swing(0.3, _leftMidStart.transform, _leftMidEnd.transform)
		2:
			_nextSwingType = 0
			#_run_swing(0.2, _thrustStart.transform, _thrustEnd.transform)
			_run_swing(0.2, _centreChopEnd.transform, _centreChopStart.transform)
		3:
			_nextSwingType = 3
			_run_swing(0.2, _centreChopStart.transform, _centreChopEnd.transform)

func _get_move_based_swing_type(move:Vector2) -> int:
	if move.is_zero_approx():
		return 3
	if move.x < 0:
		return 1
	elif move.x > 0:
		return 0
	elif move.y > 0:
		return 2
	return 3
#	var lookMoveDegrees:float = rad_to_deg(atan2(_mouseDelta.y, _mouseDelta.x))
#	if lookMoveDegrees

func _get_look_based_swing_type(look:Vector2) -> int:
	var lookMoveDegrees:float = rad_to_deg(atan2(_mouseDelta.y, _mouseDelta.x))
	lookMoveDegrees = ZqfUtils.cap_degrees(lookMoveDegrees)
	# up 270, down 90, right 0, left 180
	# +x is right, +y is down
#	if lookMoveDegrees < 
	
	return 2

func _physics_process_attack(_delta:float) -> void:
	if Input.is_action_pressed("attack_2") && !_swinging:
		_leftHand.rotation_degrees.y = 0
	else:
		_leftHand.rotation_degrees.y = 125
	if _swinging:
		return
	if Input.is_action_pressed("attack_1"):
		
		_nextSwingType = _get_move_based_swing_type(_movePushDelta)
		#_nextSwingType = _get_move_based_swing_type(_mouseDelta.normalized())
		_auto_swing()
	elif Input.is_action_pressed("attack_3"):
		_run_swing(0.2, _thrustStart.transform, _thrustEnd.transform)
		

func _process(delta:float):
	_timeSinceLastMouseDelta += delta
	if _swinging:
		_tick += delta
		if _tick > _tickMax:
			_tick = 0.0
			_swinging = false
		var weight:float = _tick / _tickMax
		_weaponModel.transform = _a.interpolate_with(_b, weight)
	
	if _timeSinceLastMouseDelta < 0.05:
		var lookMoveDegrees:float = rad_to_deg(atan2(_mouseDelta.y, _mouseDelta.x))
		_lookDirIcon.rotation_degrees = lookMoveDegrees
		lookMoveDegrees = ZqfUtils.cap_degrees(lookMoveDegrees)
		#print(str(lookMoveDegrees) + " from " + str(_mouseDelta))
	else:
		_lookDirIcon.rotation_degrees = 270
	
	if !_movePushDelta.is_zero_approx():
		var movePushDegrees:float = rad_to_deg(atan2(_movePushDelta.y, _movePushDelta.x))
		_moveDirIcon.rotation_degrees = movePushDegrees
	else:
		_moveDirIcon.rotation_degrees = 270

###################################################
# Movement
###################################################

func _physics_process_move(delta:float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	_movePushDelta = input_dir
	
	if Zqf.has_mouse_claims():
		input_dir = Vector2()
	var direction:Vector3 = (_head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func _input(event) -> void:
	if Zqf.has_mouse_claims():
		return
	var motion:InputEventMouseMotion = event as InputEventMouseMotion
	if motion == null:
		return
	var ratio:Vector2 = ZqfUtils.get_window_to_screen_ratio()
	var invertedMul:float = -1
	
	var dx:float = (-motion.relative.x) * 0.2 * ratio.x
	var dy:float = ((-motion.relative.y) * 0.2) * ratio.y * invertedMul
	
	_timeSinceLastMouseDelta = 0.0
	_mouseDelta.x = -dx
	_mouseDelta.y = -dy

	# apply
	var degrees:Vector3 = _head.rotation_degrees
	degrees.y += dx
	degrees.x += dy
	degrees.x = clampf(degrees.x, -89, 89)
	_head.rotation_degrees = degrees

func _physics_process(delta):
	_physics_process_move(delta)
	_physics_process_attack(delta)
