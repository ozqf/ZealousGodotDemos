extends CharacterBody3D

@onready var _yaw:Node3D = $yaw
@onready var _pitch:Node3D = $yaw/head

@export var playAreaOrigin:Vector3 = Vector3()
@export var playAreaRadius:float = 200

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	
	var horizontalPush:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var verticalPush:float = Input.get_axis("move_down", "move_up")
	
	var friction:float = 0.95
	var accel:float = 20.0
	var maxSpeed:float = 25
	
	
	if horizontalPush.is_zero_approx() && is_zero_approx(verticalPush):
		var vel:Vector3 = self.velocity
		vel.x *= friction
		vel.y *= friction
		#vel.y += (-20.0) * delta
		vel.z *= friction
		self.velocity = vel
		
		pass
	else:
		var footPush:Vector3 = input_to_push_vector_flat(horizontalPush, _yaw.basis)
		
		var v:Vector3 = self.velocity
		#var y:float = v.y
		#y = 0
		v += footPush * accel * delta
		if verticalPush > 0:
			v.y += (1.0 * accel) * delta
		if verticalPush < 0:
			v.y += (-1.0 * accel) * delta
		v = v.limit_length(maxSpeed)
		#v.y = y + (-20.0 * delta)
		self.velocity = v
	
	# apply push stronger than player toward origin if they are too far away
	if self.global_position.distance_to(playAreaOrigin) > playAreaRadius:
		var toward:Vector3 = self.global_position.direction_to(playAreaOrigin)
		self.velocity += (toward * accel * 2) * delta
	
	self.move_and_slide()
	pass

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
