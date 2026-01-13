extends CharacterBody3D

@onready var _yaw:Node3D = $yaw
@onready var _pitch:Node3D = $yaw/head
@onready var _groundRay:RayCast3D = $ground_ray
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if _groundRay.is_colliding() && Input.is_action_just_pressed("move_up"):
		self.velocity.y = 11.0
	self.velocity.y += (-20.0 * delta)
	
	var platformAxes:Basis = get_parent_node_3d().global_basis
	var inputPush:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if inputPush.is_zero_approx():
		var v:Vector3 = self.velocity
		v.x *= 0.8
		v.z *= 0.8
		self.velocity = v
		pass
	else:
		var footPush:Vector3 = input_to_push_vector_flat(inputPush, _yaw.basis)
		var projectionZ:Vector3 = footPush.project(platformAxes.z)
		#print(str(projectionZ))
		footPush = projectionZ
		var v:Vector3 = self.velocity
		var y:float = v.y
		#y = 0
		v += footPush * 150.0 * delta
		v = v.limit_length(8)
		v.y = y
		# limit velocity to 2d line
		# 
		self.velocity = v
		
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
