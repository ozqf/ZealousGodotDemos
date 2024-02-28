extends RigidBody3D

@onready var _cameraChaser:Node3D = $camera_chaser
@onready var _cameraBlockRay:RayCast3D = $camera_chaser/RayCast3D
@onready var _cameraTarget:Node3D = $camera_chaser/camera_target
@onready var _cameraMount:Node3D = $camera_chaser/camera_mount
@onready var _debugLabel:Label3D = $debug_label

@onready var _groundRay:RayCast3D = $ground_ray
@onready var _downRay:RayCast3D = $ground_ray

@onready var _bodyMesh:Node3D = $display

var _lastNoneZeroVelocity:Vector3 = Vector3.FORWARD

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
	return Vector3(0, 1, 0)

func _physics_process(__delta) -> void:
	var debugTxt:String = ""
	
	var surfaceNormal:Vector3 = calc_surface_normal()
	if _downRay.is_colliding():
		debugTxt += "Down: " + str(_downRay.get_collision_normal()) + "\n"
	if _groundRay.is_colliding():
		debugTxt += "Ground: " + str(_groundRay.get_collision_normal()) + "\n"
	debugTxt += "Surface: " + str(surfaceNormal) + "\n"
	_debugLabel.text = debugTxt

	#_bodyMesh.global_transform.basis = _align_to_surface_normal(_bodyMesh.global_transform.basis, surfaceNormal)
	_bodyMesh.global_transform.basis = ZqfUtils.align_to_surface(_bodyMesh.global_transform.basis, surfaceNormal)

	
	var axisX:float = Input.get_axis("move_left", "move_right")
	var axisZ:float = Input.get_axis("move_forward", "move_backward")
	var inputDir:Vector2 = Vector2(axisX, axisZ)
	var pushDir:Vector3 = ZqfUtils.input_to_push_vector_flat(inputDir, _cameraChaser.global_transform.basis)
	var prevVelocity:Vector3 = self.linear_velocity
	var newVelocity:Vector3 = prevVelocity + (pushDir * 30) * __delta
	
	if Input.is_action_pressed("move_down"):
		newVelocity.x *= 0.95
		newVelocity.z *= 0.95
	
	if Input.is_action_just_pressed("move_up") && newVelocity.y < 10:
		newVelocity.y = 20.0
	newVelocity.y += (-10 * __delta)
	self.linear_velocity = newVelocity
	#self.move_and_slide()
	
	pass

func _process(__delta) -> void:
	if !_cameraBlockRay.is_colliding():
		_cameraMount.position = _cameraTarget.position
	else:
		_cameraMount.global_position = _cameraBlockRay.get_collision_point()
	var chasePosCurrent:Vector3 = _cameraChaser.global_position
	var chasePosTarget:Vector3 = self.global_position
	_cameraChaser.global_position = chasePosCurrent.lerp(chasePosTarget, 0.9)

func _input(event) -> void:
	if Game.has_mouse_claims():
		return
	var motion:InputEventMouseMotion = event as InputEventMouseMotion
	if motion == null:
		return
	var degrees:Vector3 = _cameraChaser.rotation_degrees
	degrees.y += (-motion.relative.x) * 0.2
	_cameraChaser.rotation_degrees = degrees
	
	#degrees = _cameraChaser.rotation_degrees
	#degrees.x += (motion.relative.y) * 0.2
	#_cameraChaser.rotation_degrees = degrees
