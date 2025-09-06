extends Node3D
class_name CameraRig

@onready var _yaw:Node3D = $yaw_pivot
@onready var _pitch:Node3D = $yaw_pivot/pitch_pivot

var _timeSinceLastMouseDelta:float = 0.0
var _mouseDelta:Vector2 = Vector2()

func get_move_basis() -> Basis:
	return _yaw.global_transform.basis

func _physics_process(_delta: float) -> void:
	var turnAxis:float = Input.get_axis("turn_right", "turn_left")
	var turnDegreesPerSecond:float = 135.0
	var dx:float = turnDegreesPerSecond * _delta * turnAxis
	var degrees:Vector3 = _yaw.rotation_degrees
	degrees.y += dx
	_yaw.rotation_degrees = degrees

	pass

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

	# apply yaw
	var degrees:Vector3 = _yaw.rotation_degrees
	degrees.y += dx
	_yaw.rotation_degrees = degrees

	# apply pitch
	degrees = _pitch.rotation_degrees
	degrees.x += dy
	degrees.x = clampf(degrees.x, -89, 89)
	_pitch.rotation_degrees = degrees
