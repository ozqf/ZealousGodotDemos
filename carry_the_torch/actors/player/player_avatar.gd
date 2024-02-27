extends RigidBody3D

@onready var _cameraChaser:Node3D = $camera_chaser
@onready var _cameraBlockRay:RayCast3D = $camera_chaser/RayCast3D
@onready var _cameraTarget:Node3D = $camera_chaser/camera_target
@onready var _cameraMount:Node3D = $camera_chaser/camera_mount

func _ready():
	ZqfUtils.disable_mouse_cursor()

func _physics_process(__delta) -> void:
	var axisX:float = Input.get_axis("move_left", "move_right")
	var axisZ:float = Input.get_axis("move_forward", "move_backward")
	var inputDir:Vector2 = Vector2(axisX, axisZ)
	var pushDir:Vector3 = ZqfUtils.input_to_push_vector_flat(inputDir, _cameraChaser.global_transform.basis)
	var prevVelocity:Vector3 = self.linear_velocity
	var newVelocity:Vector3 = prevVelocity + (pushDir * 40) * __delta
	
	if !Input.is_action_pressed("move_down"):
		newVelocity *= 0.95
	
	if Input.is_action_just_pressed("move_up") && newVelocity.y < 10:
		newVelocity.y = 20.0
	newVelocity.y += (-20 * __delta)
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
