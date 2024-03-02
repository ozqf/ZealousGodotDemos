extends RigidBody3D

@onready var _cameraRig:PlayerCameraRig = $camera_chaser
@onready var _debugLabel:Label3D = $surface_alignment_snap/debug_label

@onready var _groundRay:RayCast3D = $ground_ray
@onready var _downRay:RayCast3D = $display/down_ray
@onready var _surfaceSensor:Area3D = $surface_area_sensor

@onready var _surfaceSnap:Node3D = $surface_alignment_snap
@onready var _bodyMesh:Node3D = $display

var _lastSurfaceNormal:Vector3 = Vector3.UP
var _isOnSurface:bool = true
var _pitchInverted:bool = true

func _ready():
	ZqfUtils.disable_mouse_cursor()

func calc_surface_normal(isOnSurface:bool) -> Vector3:
	if _downRay.is_colliding():
		return _downRay.get_collision_normal()
	elif _groundRay.is_colliding():
		return _groundRay.get_collision_normal()
	return _lastSurfaceNormal
	#return _cameraRig.get_floating_input_basis().y

func _physics_process(_delta) -> void:
	var debugTxt:String = ""
	
	#var _isOnSurface:bool = _downRay.is_colliding() || _groundRay.is_colliding()
	_isOnSurface = _surfaceSensor.has_overlapping_bodies()
	var prevVelocity:Vector3 = self.linear_velocity
	var prevSpeed:float = self.linear_velocity.length()
	var pushBasis:Basis = _cameraRig.get_surface_input_basis()
	if !_isOnSurface:
		pushBasis = _cameraRig.get_floating_input_basis()
	var surfaceNormal:Vector3 = calc_surface_normal(_isOnSurface)
	var surfaceChanged:bool = !surfaceNormal.is_equal_approx(_lastSurfaceNormal)
	if surfaceChanged:
		print("Surface changed, " + str(_lastSurfaceNormal) + " to " + str(surfaceNormal))
		_surfaceSnap.global_transform.basis = ZqfUtils.align_to_surface(_surfaceSnap.global_transform.basis, surfaceNormal)
	_lastSurfaceNormal = surfaceNormal
	
	_bodyMesh.global_transform.basis = _bodyMesh.global_transform.basis.orthonormalized()
	var current:Basis = _bodyMesh.global_transform.basis.orthonormalized()
	var target:Basis = current.slerp(_surfaceSnap.global_transform.basis, 0.3)
	
	_bodyMesh.global_transform.basis = target
	var t:Transform3D = _bodyMesh.global_transform

	if _isOnSurface:
		var lookTarget:Vector3 = t.origin + -pushBasis.z
		_bodyMesh.look_at(lookTarget, target.y)
	else:
		var lookTarget:Vector3 = t.origin + -_cameraRig.get_floating_input_basis().z
		_bodyMesh.look_at(lookTarget, target.y)
	
	# align camera
	_cameraRig.set_surface_normal(surfaceNormal)
	
	# input to world push direction
	var axisX:float = Input.get_axis("move_left", "move_right")
	var axisZ:float = Input.get_axis("move_forward", "move_backward")
	var inputDir:Vector2 = Vector2(axisX, axisZ)
	var pushDir:Vector3 = ZqfUtils.input_to_push_vector_flat(inputDir, pushBasis)
	
	# calc push strength
	var pushStr:float = 120 if _isOnSurface else 20
	var pushToApply:Vector3 = (pushDir * pushStr)
	# scale by dot product and range to maximum
	var maxSpeed:float = 40.0
	var speedWeight:float = prevSpeed / maxSpeed
	
	if inputDir.is_equal_approx(Vector2.ZERO):
		speedWeight = 1.0
	
	var drag:Vector3 = Vector3.ZERO
	
	if _isOnSurface:
		var drag1:Vector3 = -pushToApply * speedWeight
		var drag2:Vector3 = (-prevVelocity.normalized()) * pushToApply.length() * speedWeight
		drag = drag2
	
	var newVelocity:Vector3 = prevVelocity + (pushToApply * _delta) + (drag * _delta)
	
	if _downRay.is_colliding():
		if Input.is_action_just_pressed("move_up"):
			newVelocity += surfaceNormal * 10
		# if the player is not on flat ground, pull them onto the surface slightly
		# otherwise they can drift off
		if surfaceNormal.dot(Vector3.UP) != 1:
			newVelocity += (-surfaceNormal) * 5 * _delta
	else:
		# apply regular gravity
		newVelocity.y += (-5 * _delta)
	
	self.linear_velocity = newVelocity
	
	# debug text
	debugTxt += str(prevSpeed) + "m/s\n"
	debugTxt += "Speed % " + str(speedWeight) + "\n"
	debugTxt += "On Surface: " + str(_isOnSurface) + "\n"
	if _downRay.is_colliding():
		debugTxt += "Down: " + str(_downRay.get_collision_normal()) + "\n"
	else:
		debugTxt += "Down - no collision\n"
	if _groundRay.is_colliding():
		debugTxt += "Ground: " + str(_groundRay.get_collision_normal()) + "\n"
	else:
		debugTxt += "Ground - no collision\n"
	debugTxt += "Surface: " + str(surfaceNormal) + "\n"
	_debugLabel.text = debugTxt

func _input(event) -> void:
	if Game.has_mouse_claims():
		return
	var motion:InputEventMouseMotion = event as InputEventMouseMotion
	if motion == null:
		return
	
	var degreesYaw:float = (-motion.relative.x) * 0.2
	var degreesPitch:float = (-motion.relative.y) * 0.2
	# inverted?
	if _pitchInverted:
		degreesPitch = -degreesPitch
	_cameraRig.apply_yaw_rotation(degreesYaw)
	#if _isOnSurface:
	_cameraRig.apply_pitch_rotation(degreesPitch)
	#_cameraRig.on_input(event)
