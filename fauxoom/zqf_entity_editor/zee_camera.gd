extends Node3D

const EdEnums = preload("res://zqf_entity_editor/zee_enums.gd")

const MOUSE_MOVE_SCALE:float = 0.1
const PITCH_CAP_DEGREES = 89
const KEYBOARD_YAW_DEGREES = 180

var mouseSensitivity: float = 1
var invertedY:bool = true

var m_yaw: float = 0
var m_pitch: float = 0
var _enabled:bool = true
var inputOn:bool = true
var _flyOn:bool = true
var turningOn:bool = true
var _head:Node3D = null
var _speed:float = 10.0

func _ready() -> void:
	add_to_group(EdEnums.GROUP_NAME)
	_head = self

func zee_on_global_enabled() -> void:
	print("Enabled editor camera")
	_enabled = true
	visible = true
	$Camera.current = true
	set_fly_camera_enabled(_flyOn)

func zee_on_global_disabled() -> void:
	print("Disable editor camera")
	_enabled = false
	visible = false
	$Camera.current = false
	# make sure cursor lock is cleared
	_refresh_mouse_claim()

func reset() -> void:
	global_transform = Transform3D.IDENTITY

func set_fly_camera_enabled(flag:bool) -> void:
	_flyOn = flag
	if _flyOn:
		inputOn = true
		turningOn = true
	else:
		inputOn = true
		turningOn = false
	_refresh_mouse_claim()
	
func _refresh_mouse_claim() -> void:
	if inputOn && _enabled && !_flyOn:
		MouseLock.add_claim(get_tree(), "EntityEditor")
	else:
		MouseLock.remove_claim(get_tree(), "EntityEditor")

func _apply_rotations(_delta: float):
	m_yaw = ZqfUtils.cap_degrees(m_yaw)
	var bodyRot:Vector3 = _head.rotation_degrees
	bodyRot.y = m_yaw
	_head.rotation_degrees = bodyRot

	m_pitch = clamp(m_pitch, -PITCH_CAP_DEGREES, PITCH_CAP_DEGREES)
	var camRot:Vector3 = _head.rotation_degrees
	camRot.x = m_pitch
	_head.rotation_degrees = camRot

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
	if Input.is_action_pressed("move_up"):
		input.y += 1
	if Input.is_action_pressed("move_down"):
		input.y -= 1
	return input

func _read_rotation_keys(_delta:float) -> void:
	if Input.is_action_pressed("ui_left"):
		m_yaw += _delta * KEYBOARD_YAW_DEGREES
	if Input.is_action_pressed("ui_right"):
		m_yaw -= _delta * KEYBOARD_YAW_DEGREES

# Process mouse input via raw input events, if mouse is captured
func _input(_event: InputEvent):
	if !inputOn || !_enabled || !turningOn:
		return
	if Game.debuggerOpen:
		return
	if _event is InputEventMouseMotion:
		# NOTE: Apply input to m_pitch/m_yaw values. But do not
		# set spatial rotations yet.

		# scale inputs by this ratio or mouse sensitivity is based on resolution!
		var scrSizeRatio: Vector2 = ZqfUtils.get_window_to_screen_ratio()
		
		# Horizontal
		var moveMul:float = mouseSensitivity * MOUSE_MOVE_SCALE
		var mMoveX: float = (_event.relative.x * moveMul) * scrSizeRatio.x
		# flip as we want moving mouse to the right to rotate LEFT (anti-clockwise)
		mMoveX = -mMoveX
		#var rotY: float = deg_to_rad(mMoveX)
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

func _process(_delta:float) -> void:
	if !inputOn || !_enabled:
		return
	if turningOn:
		_read_rotation_keys(_delta)
		_apply_rotations(_delta)

	var input:Vector3 = _read_input()
	
	var t:Transform3D = _head.global_transform
	var forward:Vector3 = t.basis.z
	var left:Vector3 = t.basis.x
	var up:Vector3 = t.basis.y

	var push:Vector3 = Vector3()
	push += (forward * input.z)
	push += (left * input.x)
	push += (up * input.y)
	push *= _speed

	var pos:Vector3 = global_transform.origin
	pos += push * _delta
	global_transform.origin = pos
