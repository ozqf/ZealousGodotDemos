extends RigidBody3D

@onready var _cameraRig:PlayerCameraRig = $camera_chaser
@onready var _cameraChaser:Node3D = $camera_chaser
#@onready var _cameraBlockRay:RayCast3D = $camera_chaser/RayCast3D
#@onready var _cameraTarget:Node3D = $camera_chaser/camera_target
#@onready var _cameraMount:Node3D = $camera_chaser/camera_mount
@onready var _debugLabel:Label3D = $debug_label

@onready var _groundRay:RayCast3D = $ground_ray
@onready var _downRay:RayCast3D = $display/down_ray

@onready var _surfaceSnap:Node3D = $surface_alignment_snap
@onready var _bodyMesh:Node3D = $display

#var _lastNoneZeroVelocity:Vector3 = Vector3.FORWARD
var _lastSurfaceNormal:Vector3 = Vector3.UP

func _ready():
	ZqfUtils.disable_mouse_cursor()

func align_to_surface_normal(_basis:Basis, normal:Vector3) -> Basis:
	_basis.y = normal
	_basis.x = -_basis.z.cross(normal)
	return _basis.orthonormalized()

func calc_surface_normal() -> Vector3:
	if _downRay.is_colliding():
		return _downRay.get_collision_normal()
	elif _groundRay.is_colliding():
		return _groundRay.get_collision_normal()
	return _lastSurfaceNormal

func _physics_process(_delta) -> void:
	var debugTxt:String = ""
	
	var surfaceNormal:Vector3 = calc_surface_normal()
	var surfaceChanged:bool = surfaceNormal.is_equal_approx(_lastSurfaceNormal)
	_lastSurfaceNormal = surfaceNormal
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

	_surfaceSnap.global_transform.basis = ZqfUtils.align_to_surface(_surfaceSnap.global_transform.basis, surfaceNormal)
	var current:Basis = _bodyMesh.global_transform.basis
	var target:Basis = current.slerp(_surfaceSnap.global_transform.basis, 0.1)
	_bodyMesh.global_transform.basis = target
	var t:Transform3D = _bodyMesh.global_transform


	#var lookTarget:Vector3 = t.origin + (t.origin - _cameraMount.global_transform.origin)
	#_bodyMesh.look_at(lookTarget, target.y)
	#if self.linear_velocity.length_squared() > 0:
	#	_bodyMesh.look_at()
	
	# align camera
	#if align_with_y:
	_cameraRig.set_surface_normal(surfaceNormal)
	#_cameraChaser.global_transform.basis = ZqfUtils.align_to_surface(_cameraChaser.global_transform.basis, surfaceNormal)
	#_cameraChaser.global_transform = ZqfUtils.align_with_y(_cameraChaser.global_transform, surfaceNormal)
	
	var axisX:float = Input.get_axis("move_left", "move_right")
	var axisZ:float = Input.get_axis("move_forward", "move_backward")
	var inputDir:Vector2 = Vector2(axisX, axisZ)
	var pushBasis:Basis = _cameraRig.get_input_basis()
	var pushDir:Vector3 = ZqfUtils.input_to_push_vector_flat(inputDir, pushBasis)
	var prevVelocity:Vector3 = self.linear_velocity
	var newVelocity:Vector3 = prevVelocity + (pushDir * 30) * _delta
	
	
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
	
	#if Input.is_action_pressed("move_down"):
	#	newVelocity.x *= 0.95
	#	newVelocity.z *= 0.95
	
	# jump
	#if Input.is_action_just_pressed("move_up") && newVelocity.y < 10:
	#	newVelocity.y = 20.0
	
	# jetpack
	#if Input.is_action_pressed("move_up"):
	#	newVelocity.y += 15.0 * _delta
	#else:
	#	newVelocity.y += (-5 * _delta)
	self.linear_velocity = newVelocity
	#self.move_and_slide()
	
	pass

#func _process(_delta) -> void:
#	if !_cameraBlockRay.is_colliding():
#		_cameraMount.position = _cameraTarget.position
#	else:
#		_cameraMount.global_position = _cameraBlockRay.get_collision_point()
#	var chasePosCurrent:Vector3 = _cameraChaser.global_position
#	var chasePosTarget:Vector3 = self.global_position
#	_cameraChaser.global_position = chasePosCurrent.lerp(chasePosTarget, 0.9)

#func _input(event) -> void:
#	if Game.has_mouse_claims():
#		return
#	var motion:InputEventMouseMotion = event as InputEventMouseMotion
#	if motion == null:
#		return
#	
#	var degreesChangeX:float = (-motion.relative.x) * 0.2
#	var degreesChangeY:float = (-motion.relative.y) * 0.2
#	_cameraChaser.rotate(_cameraChaser.basis.y, degreesChangeX * ZqfUtils.DEG2RAD)
#	_cameraChaser.rotate(_cameraChaser.basis.x, degreesChangeY * ZqfUtils.DEG2RAD)
	
	#var degrees:Vector3 = _cameraChaser.rotation_degrees
	#degrees.y += degreesChangeX
	#_cameraChaser.rotation_degrees = degrees
	#_cameraChaser.rotate(_cameraChaser.basis.y, degreesChangeX * ZqfUtils.DEG2RAD)
	
	#degrees = _cameraChaser.rotation_degrees
	#degrees.x += (motion.relative.y) * 0.2
	#_cameraChaser.rotation_degrees = degrees
