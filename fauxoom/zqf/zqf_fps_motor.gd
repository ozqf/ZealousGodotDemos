extends Node
class_name ZqfFPSMotor

const MOUSE_MOVE_SCALE:float = 0.1
const PITCH_CAP_DEGREES = 89
const KEYBOARD_YAW_DEGREES = 180

const RUN_SPEED:float = 8.5
const GROUND_ACCELERATION:float = 150.0
const GROUND_FRICTION:float = 0.8
const AIR_ACCELERATION:float = 50.0

const DASH_SPEED:float = 20.0
const DASH_DURATION:float = 0.25
const ENERGY_MAX:float = 100.0
const DASH_ENERGY_COST:float = 50.0
const ENERGY_GAIN_PER_SECOND:float = 50.0

const GRAVITY:float = 20.0

var mouseSensitivity: float = 1
var invertedY:bool = false

var _body:KinematicBody = null
var _head:Spatial = null
var _inputOn:bool = false
var _velocity:Vector3 = Vector3()

var _dashTime:float = 0
var energy:float = ENERGY_MAX
var _dashPushDir:Vector3 = Vector3()

var m_yaw: float = 0
var m_pitch: float = 0

func set_input_enabled(flag:bool) -> void:
	if _inputOn == flag:
		return
	_inputOn = flag

func get_velocity() -> Vector3:
	return _velocity

func get_sway_scale() -> float:
	return _velocity.length() / RUN_SPEED

func init_motor(body:KinematicBody, head:Spatial) -> void:
	_body = body
	_head = head

func set_yaw_degrees(_yawDegrees:float) -> void:
	# set yaw to current rotation, or if spawned at an angle
	# yaw will act like an offset instead!
	var headRot:Vector3 = _body.rotation_degrees
	headRot.x = 0
	headRot.y = _yawDegrees
	headRot.z = 0
	_head.rotation_degrees = headRot
	m_yaw = _yawDegrees

func _read_input() -> Vector3:
	var input:Vector3 = Vector3()
	if Input.is_action_pressed("move_forward"):
		input.z -= 1
	if Input.is_action_pressed("move_backward"):
		input.z += 1
	if Input.is_action_pressed("move_left"):
		input.x -= 1
	if Input.is_action_pressed("move_right"):
		input.x += 1
	return input

func _read_rotation_keys(_delta:float) -> void:
	if Input.is_action_pressed("ui_left"):
		m_yaw += _delta * KEYBOARD_YAW_DEGREES
	if Input.is_action_pressed("ui_right"):
		m_yaw -= _delta * KEYBOARD_YAW_DEGREES

func _apply_rotations(_delta: float):
	m_yaw = ZqfUtils.cap_degrees(m_yaw)
	var bodyRot:Vector3 = _head.rotation_degrees
	bodyRot.y = m_yaw
	_head.rotation_degrees = bodyRot

	m_pitch = clamp(m_pitch, -PITCH_CAP_DEGREES, PITCH_CAP_DEGREES)
	var camRot:Vector3 = _head.rotation_degrees
	camRot.x = m_pitch
	_head.rotation_degrees = camRot

func _physics_process(delta:float) -> void:
	if _body == null:
		return
	if !_inputOn:
		return
	_read_rotation_keys(delta)
	_apply_rotations(delta)

	energy += ENERGY_GAIN_PER_SECOND * delta
	if energy > ENERGY_MAX:
		energy = ENERGY_MAX

	if _dashTime > 0:
		_dashTime -= delta
		if _dashTime <= 0:
			# stop dash
			_velocity = Vector3()
		else:
			_velocity = _dashPushDir * DASH_SPEED
			_velocity = _body.move_and_slide(_velocity)
			return

	var input:Vector3 = _read_input()
	var t:Transform = _head.global_transform
	var forward:Vector3 = t.basis.z
	var left:Vector3 = t.basis.x
	var pushDir:Vector3 = Vector3()
	var isOnFloor:bool = _body.is_on_floor()
	
	pushDir += (forward * input.z)
	pushDir += (left * input.x)
	pushDir.y = 0
	pushDir = pushDir.normalized()
	var pushing:bool = (pushDir.length() > 0)
	
	var dashOn:bool = Input.is_action_pressed("move_special")
	if dashOn && energy >= DASH_ENERGY_COST && _dashTime <= 0:
		_dashTime = DASH_DURATION
		energy -= DASH_ENERGY_COST
		# if current input, dash dir is just forwards
		if pushing:
			_dashPushDir = pushDir
		else:
			_dashPushDir = -forward
			_dashPushDir.y = 0
			_dashPushDir = _dashPushDir.normalized()
		_velocity = _dashPushDir * DASH_SPEED
		_velocity = _body.move_and_slide(_velocity)
		return
	
	var flatVelocity:Vector3 = _velocity
	flatVelocity.y = 0
	# calculate current speed cap
	if pushing:
		var currentSpeed:float = flatVelocity.length()
		var velocityCap = RUN_SPEED
		# speed cap is run speed unless pushed externally
		if currentSpeed > velocityCap:
			velocityCap = currentSpeed
		var accel:float = GROUND_ACCELERATION
		if !isOnFloor:
			accel = AIR_ACCELERATION
		flatVelocity += (pushDir * accel) * delta
		# apply speed cap
		if flatVelocity.length() > velocityCap:
			flatVelocity = flatVelocity.normalized() * velocityCap
	else:
		# apply ground friction to stop player
		flatVelocity *= GROUND_FRICTION
	
	# force stop below threshold
	if flatVelocity.length() < 0.01:
		flatVelocity = Vector3()
	
	_velocity.x = flatVelocity.x
	_velocity.z = flatVelocity.z
	if Input.is_action_pressed("move_up") && isOnFloor:
		_velocity.y = 7
	# gravity
	_velocity.y -= GRAVITY * delta
	
	_velocity = _body.move_and_slide(_velocity, Vector3.UP)

func _get_window_to_screen_ratio():
	var real: Vector2 = OS.get_real_window_size()
	var scr: Vector2 = OS.get_screen_size()
	var result: Vector2 = Vector2(real.x / scr.x, real.y / scr.y)
	return result

# Process mouse input via raw input events, if mouse is captured
func _input(_event: InputEvent):
	if !_inputOn:
		return
	if _event is InputEventMouseMotion:
		# NOTE: Apply input to m_pitch/m_yaw values. But do not
		# set spatial rotations yet.

		# scale inputs by this ratio or mouse sensitivity is based on resolution!
		var scrSizeRatio: Vector2 = _get_window_to_screen_ratio()
		# var scrSizeRatio: Vector2 = Vector2(1, 1)

		# Horizontal
		var moveMul:float = mouseSensitivity * MOUSE_MOVE_SCALE
		var mMoveX: float = (_event.relative.x * moveMul) * scrSizeRatio.x
		# flip as we want moving mouse to the right to rotate LEFT (anti-clockwise)
		mMoveX = -mMoveX
		#var rotY: float = deg2rad(mMoveX)
		m_yaw += mMoveX

		# vertical
		# TODO: Uninverted mouse!
		# DISABLED - until there is a reason to mouse-look and UI to toggle inverted!
		var mMoveY: float = (_event.relative.y * moveMul * scrSizeRatio.y)
		if invertedY:
			m_pitch += mMoveY
		else:
			m_pitch -= mMoveY
	pass
