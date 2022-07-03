extends Node
class_name ZqfFPSMotor

signal moved(body, head)

const MOUSE_MOVE_SCALE:float = 0.1
const PITCH_CAP_DEGREES = 89
const KEYBOARD_YAW_DEGREES = 180

const RUN_SPEED:float = 8.5
const GROUND_ACCELERATION:float = 150.0
const AIR_ACCELERATION:float = 45.0
const GROUND_FRICTION:float = 0.75
const AIR_FRICTION:float = 0.99

const DASH_SPEED:float = 18.0
const DASH_DURATION:float = 0.25
const ENERGY_MAX:float = 100.0
const DASH_ENERGY_COST:float = 50.0
const ENERGY_GAIN_PER_SECOND:float = 50.0

const GRAVITY:float = 20.0

var mouseSensitivity: float = 1
var invertedY:bool = false
var nearWall:bool = false
var onFloor:bool = false

var _body:KinematicBody = null
var _head:Spatial = null
var _inputOn:bool = false
var _groundSlamming:bool = false
var _velocity:Vector3 = Vector3()

var _dashTime:float = 0
var _dashEmptied:bool = false
var _doubleJumps:int = 0
var energy:float = ENERGY_MAX
var _dashPushDir:Vector3 = Vector3()

var m_yaw: float = 0
var m_pitch: float = 0

func set_input_enabled(flag:bool) -> void:
	if _inputOn == flag:
		return
	_inputOn = flag

func start_ground_slam() -> void:
	if _head == null:
		return
	_groundSlamming = true
	_velocity = (-_head.global_transform.basis.z) * 25.0

func get_velocity() -> Vector3:
	return _velocity

func get_flat_velocity() -> Vector3:
	return Vector3(_velocity.x, 0, _velocity.z)

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

func custom_tick(delta:float) -> void:
#func _process(delta:float) -> void:
	if _body == null:
		return
	if !_inputOn:
		return

	# body is a capsule so cannot trust its floor detection
	# or we'll just slide off stuff
	#var isOnFloor:bool = _body.is_on_floor()
	var isOnFloor:bool = onFloor
	if isOnFloor:
		_doubleJumps = 0
	
	# if slamming, move and wait to be grounded
	if _groundSlamming:
		if isOnFloor:
			# end slam
			_groundSlamming = false
			get_tree().call_group(Groups.PLAYER_GROUP_NAME, Groups.PLAYER_FN_GROUND_SLAM_FINISH)
		else:
			_velocity.y -= GRAVITY * delta
			_velocity = _body.move_and_slide(_velocity, Vector3.UP, true)
			return
	
	_read_rotation_keys(delta)
	_apply_rotations(delta)
	
	if energy < ENERGY_MAX:
		energy += ENERGY_GAIN_PER_SECOND * delta
		# only let regen finish if on the ground
		var cap:float = ENERGY_MAX
		if !isOnFloor:
			cap -= 1
		if energy >= cap:
			_dashEmptied = false
			energy = cap
	
	if _dashTime > 0:
		_dashTime -= delta
		if _dashTime <= 0:
			# stop dash if on floor, otherwise carry velocity
			if isOnFloor:
				_velocity = _velocity.normalized() * RUN_SPEED
		else:
			# _velocity = _dashPushDir * DASH_SPEED
			
			_velocity = _body.move_and_slide(_velocity)
			# adjust dash path to align with what we've slid along
			# _dashPushDir = _velocity.normalized()
			return

	var input:Vector3 = _read_input()
	var t:Transform = _head.global_transform
	var forward:Vector3 = t.basis.z
	var left:Vector3 = t.basis.x
	var pushDir:Vector3 = Vector3()
	
	pushDir += (forward * input.z)
	pushDir += (left * input.x)
	pushDir.y = 0
	pushDir = pushDir.normalized()
	var pushing:bool = (pushDir.length() > 0)
	
	
	
	var dashOn:bool = Input.is_action_pressed("move_special")
	if dashOn && !_dashEmptied && energy >= DASH_ENERGY_COST && _dashTime <= 0 && (isOnFloor || nearWall):
		# if current input, dash dir is just forwards
		if pushing:
			_dashTime = DASH_DURATION
			energy -= DASH_ENERGY_COST
			if energy < (ENERGY_MAX / 2):
				_dashEmptied = true
			_dashPushDir = pushDir
			_velocity = _dashPushDir * DASH_SPEED
			_velocity = _body.move_and_slide(_velocity)
			return
		# Automatic dash forward if no direction is held down. Is awkward
		# when trying to do wall-dashes and isn't really necessary anyway
		#else:
		#	_dashPushDir = -forward
		#	_dashPushDir.y = 0
		#	_dashPushDir = _dashPushDir.normalized()
		#_dashTime = DASH_DURATION
		#energy -= DASH_ENERGY_COST
		#_velocity = _dashPushDir * DASH_SPEED
		#_velocity = _body.move_and_slide(_velocity)
		# return
	
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
			if isOnFloor:
				# pull back via friction
				flatVelocity *= GROUND_FRICTION
			else:
				# apply air friction to cap
				velocityCap *= AIR_FRICTION
				# cap velocity
				flatVelocity = flatVelocity.normalized() * velocityCap
			
			
	else:
		# apply ground friction to stop player
		if isOnFloor:
			flatVelocity *= GROUND_FRICTION
		else:
			flatVelocity *= AIR_FRICTION
	
	# force stop below threshold
	if flatVelocity.length() < 0.01:
		flatVelocity = Vector3()
	
	_velocity.x = flatVelocity.x
	_velocity.z = flatVelocity.z
	if Input.is_action_pressed("move_up"):
		if isOnFloor:
			_velocity.y = 7
		elif _doubleJumps == 0 && _velocity.y < 2:
			_velocity.y = 7
			_doubleJumps += 1
	# gravity
	if !isOnFloor:
		_velocity.y -= GRAVITY * delta
	
	_velocity = _body.move_and_slide(_velocity, Vector3.UP, true)
	self.emit_signal("moved", _body, _head)

func _get_window_to_screen_ratio():
	var real: Vector2 = OS.get_real_window_size()
	var scr: Vector2 = OS.get_screen_size()
	var result: Vector2 = Vector2(real.x / scr.x, real.y / scr.y)
	return result

# Process mouse input via raw input events, if mouse is captured
func _input(_event: InputEvent):
	if !_inputOn:
		return
	if Game.debuggerOpen:
		return
	if _event is InputEventMouseMotion:
		# NOTE: Apply input to m_pitch/m_yaw values. But do not
		# set spatial rotations yet.

		# scale inputs by this ratio or mouse sensitivity is based on resolution!
		var scrSizeRatio: Vector2 = _get_window_to_screen_ratio()

		# Horizontal
		var moveMul:float = mouseSensitivity * MOUSE_MOVE_SCALE
		var mMoveX: float = (_event.relative.x * moveMul) * scrSizeRatio.x
		# flip as we want moving mouse to the right to rotate LEFT (anti-clockwise)
		mMoveX = -mMoveX
		m_yaw += mMoveX

		# vertical
		var mMoveY: float = (_event.relative.y * moveMul * scrSizeRatio.y)
		if invertedY:
			m_pitch += mMoveY
		else:
			m_pitch -= mMoveY
	pass
