extends Node3D
class_name PlayerCameraMount

@onready var _head:Node3D = $head
#@onready var _aimRay:RayCast3D = $head/RayCast3D
@onready var _aimRay:RayCast3D = $head/camera_mount/RayCast3D
@onready var _aimDot:Node3D = $aim_dot
@onready var _obstructionRay:RayCast3D = $head/obstruction_ray

@onready var _camTarget:Node3D = $head/mount_max
@onready var _camMount:Node3D = $head/camera_mount

@onready var _cameraPositionOne:Node3D = $head/mount_pos_1

var inputDir:Vector3 = Vector3()

var _pushDirection:Vector3 = Vector3()

func _ready() -> void:
	_camTarget.position = _cameraPositionOne.position
	_camTarget.position = _obstructionRay.position + _obstructionRay.target_position

func get_push_direction() -> Vector3:
	return _pushDirection

func set_aim_ray_visible(flag:bool) -> void:
	#_aimRay.visible = flag
	pass

func get_head_transform() -> Transform3D:
	return _head.global_transform

func get_aim_point() -> Vector3:
	return _aimDot.global_position

func get_camera_transform() -> Transform3D:
	return _camMount.global_transform

func get_aim_collider():
	if _aimRay.is_colliding():
		return _aimRay.get_collider()
	return null

func _process(_delta:float) -> void:
	var rotDegreesPerSecond:float = 135.0
	if Input.is_action_pressed("turn_left"):
		var degrees:Vector3 = self.rotation_degrees
		degrees.y += rotDegreesPerSecond * _delta
		self.rotation_degrees = degrees
	if Input.is_action_pressed("turn_right"):
		var degrees:Vector3 = self.rotation_degrees
		degrees.y -= rotDegreesPerSecond * _delta
		self.rotation_degrees = degrees
	
	if _obstructionRay.is_colliding():
		_camMount.global_position = _obstructionRay.get_collision_point()
		pass
	else:
		_camMount.global_position = _camTarget.global_position
		pass
	
	var rayLength:float = 100
	if _aimRay.is_colliding():
		_aimDot.global_position = _aimRay.get_collision_point()
		_aimDot.scale = Vector3.ONE
	else:
		var t:Transform3D = _aimRay.global_transform
		_aimDot.global_position = t.origin + (-t.basis.z * rayLength)
		_aimDot.scale = Vector3(3, 3, 3)
	pass

	if Zqf.has_mouse_claims():
		_pushDirection = Vector3()
		return

	var input_dir:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	inputDir.x = input_dir.x
	inputDir.y = 0
	inputDir.z = input_dir.y
	_pushDirection = (self.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func _input(event) -> void:
	if Zqf.has_mouse_claims():
		return
	var motion:InputEventMouseMotion = event as InputEventMouseMotion
	if motion == null:
		return
	var degrees:Vector3 = self.rotation_degrees
	degrees.y += (-motion.relative.x) * 0.2
	self.rotation_degrees = degrees
	
	degrees = _head.rotation_degrees
	degrees.x += (motion.relative.y) * 0.2
	_head.rotation_degrees = degrees
