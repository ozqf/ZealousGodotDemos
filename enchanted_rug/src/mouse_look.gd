extends Node
class_name MouseLook

const MOUSE_SENSITIVITY: float = 0.1
const PITCH_CAP_DEGREES = 89
const KEYBOARD_YAW_DEGREES = 180.0
const KEYBOARD_PITCH_DEGREES = 180.0

var _inputOn:bool = true

var m_yaw: float = 0
var m_pitch: float = 0

var m_accumulator:Vector2 = Vector2()

func set_input_on(flag:bool) -> void:
	_inputOn = flag

func read_accumulator() -> Vector2:
	var r:Vector2 = m_accumulator
	m_accumulator = Vector2()
	return r

func _get_window_to_screen_ratio():
	var real: Vector2 = OS.get_real_window_size()
	var scr: Vector2 = OS.get_screen_size()
	var result: Vector2 = Vector2(real.x / scr.x, real.y / scr.y)
	return result

func _process(_delta:float) -> void:
	if Input.is_action_pressed("ui_left"):
		m_accumulator.x += KEYBOARD_YAW_DEGREES * _delta
	if Input.is_action_pressed("ui_right"):
		m_accumulator.x -= KEYBOARD_YAW_DEGREES * _delta
	if Input.is_action_pressed("ui_up"):
		m_accumulator.y -= KEYBOARD_PITCH_DEGREES * _delta
	if Input.is_action_pressed("ui_down"):
		m_accumulator.y += KEYBOARD_PITCH_DEGREES * _delta

# Process mouse input via raw input events, if mouse is captured
func _input(_event: InputEvent):
	if !_inputOn:
		return
	if _event is InputEventMouseMotion:
		# scale inputs by this ratio or mouse sensitivity is based on resolution!
		var scrSizeRatio: Vector2 = _get_window_to_screen_ratio()
		
		# Horizontal
		var mMoveX: float = (_event.relative.x * MOUSE_SENSITIVITY) * scrSizeRatio.x
		# flip as we want moving mouse to the right to rotate LEFT (anti-clockwise)
		mMoveX = -mMoveX
		m_yaw += mMoveX

		# vertical
		var mMoveY: float = (_event.relative.y * MOUSE_SENSITIVITY * scrSizeRatio.y)
		m_pitch += mMoveY
		
		m_accumulator.x += mMoveX
		m_accumulator.y += mMoveY
