extends Node
class_name FPSMotor

const MOUSE_SENSITIVITY: float = 0.1
const PITCH_CAP_DEGREES = 89
const KEYBOARD_YAW_DEGREES = 180

var _body:KinematicBody = null
var _head:Spatial = null
var _inputOn:bool = false

var m_yaw: float = 0
var m_pitch: float = 0

func set_input_enabled(flag:bool) -> void:
	if _inputOn == flag:
		return
	_inputOn = flag
	if _inputOn:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func init_motor(body:KinematicBody, head:Spatial) -> void:
	_body = body
	_head = head
	print("FPS Motor init")

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
	var input:Vector3 = _read_input()
	var t:Transform = _head.global_transform
	var forward:Vector3 = t.basis.z
	var left:Vector3 = t.basis.x
	var speed:float = 10.0
	var pushDir:Vector3 = Vector3()
	
	pushDir += (forward * input.z)
	pushDir += (left * input.x)
	pushDir.y = 0
	pushDir = pushDir.normalized()
	
	var _result = _body.move_and_slide(pushDir * speed)

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
		var mMoveX: float = (_event.relative.x * MOUSE_SENSITIVITY) * scrSizeRatio.x
		# flip as we want moving mouse to the right to rotate LEFT (anti-clockwise)
		mMoveX = -mMoveX
		#var rotY: float = deg2rad(mMoveX)
		m_yaw += mMoveX

		# vertical
		# TODO: Uninverted mouse!
		# DISABLED - until there is a reason to mouse-look and UI to toggle inverted!
#		var mMoveY: float = (_event.relative.y * MOUSE_SENSITIVITY * scrSizeRatio.y)
#		m_pitch += mMoveY
	pass
