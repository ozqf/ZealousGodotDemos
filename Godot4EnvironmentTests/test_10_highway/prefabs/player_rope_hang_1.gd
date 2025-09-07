extends Node3D

@onready var _yaw:Node3D = $yaw
@onready var _pitch:Node3D = $yaw/head

var _velocity:Vector3 = Vector3()
var _hangNode:Node3D = null
var _hangDistance:float = -3.0
var _swingOffset:Vector3 = Vector3()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_hangNode = get_parent()

func spawn(ropeNode:Node3D, hangDistance:float = -3) -> void:
	_hangNode = ropeNode
	pass

func _physics_process(_delta:float) -> void:
	_swing_move(_delta)

func _swing_move(_delta:float) -> void:
	if _hangNode == null:
		return
	var inputPush:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var footPush:Vector3 = input_to_push_vector_flat(inputPush, _yaw.basis)
	
	var offset:Vector3 = _swingOffset
	offset += (footPush * 5) * _delta
	var drag:Vector3 = (-offset * 3) * _delta
	offset += drag
	_swingOffset = offset
	
	var ropeOrigin:Vector3 = _hangNode.global_position
	ropeOrigin.y += _hangDistance
	ropeOrigin += _swingOffset
	self.global_position = ropeOrigin
	_hangNode.face_hang_target(ropeOrigin)

func _swing_move_old(_delta:float) -> void:
	var inputPush:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var footPush:Vector3 = input_to_push_vector_flat(inputPush, _yaw.basis)
	
	var pos:Vector3 = self.position
	var y:float = pos.y
	pos += (footPush * 5) * _delta
	var drag:Vector3 = (-pos * 3) * _delta
	pos += drag
	pos.y = y
	self.position = pos

func _basic_move(_delta:float) -> void:
	var inputPush:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var root:Node3D = get_parent_node_3d()
	
	var pos:Vector3 = self.position
	
	var footPush:Vector3 = input_to_push_vector_flat(inputPush, _yaw.basis)
	pos += (footPush * 3) * _delta
	
	pos.x = clampf(pos.x, -2, 2)
	pos.z = clampf(pos.z, -2, 2)
	self.position = pos

func _input(event: InputEvent) -> void:
	var motion:InputEventMouseMotion = event as InputEventMouseMotion
	if motion == null:
		return
	
	var ratio:Vector2 = get_window_to_screen_ratio()
	var _pitchInverted:bool = true
	var degreesYaw:float = (-motion.relative.x) * 0.2 * ratio.y
	var degreesPitch:float = (-motion.relative.y) * 0.2 * ratio.x
	# inverted?
	if _pitchInverted:
		degreesPitch = -degreesPitch
	
	var rot:Vector3 = _yaw.rotation_degrees
	rot.y += degreesYaw
	_yaw.rotation_degrees = rot
	
	rot = _pitch.rotation_degrees
	rot.x += degreesPitch
	
	_pitch.rotation_degrees = rot

static func input_to_push_vector_flat(inputDir:Vector2, basis:Basis) -> Vector3:
	var _pushDirection:Vector3 = (basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	return _pushDirection

static func get_window_to_screen_ratio(windowIndex:int = 0) -> Vector2:
	var screen: Vector2 = DisplayServer.screen_get_size()
	var window: Vector2 = DisplayServer.window_get_size(windowIndex)
	var result: Vector2 = Vector2(window.x / screen.x, window.y / screen.y)
	return result
