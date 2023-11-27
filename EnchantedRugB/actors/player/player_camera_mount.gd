extends Node3D
class_name PlayerCameraMount

@onready var _head:Node3D = $head
@onready var _aimRay:RayCast3D = $head/camera_mount/RayCast3D
@onready var _aimDot:Node3D = $aim_dot
@onready var _obstructionRay:RayCast3D = $head/obstruction_ray

@onready var _camTarget:Node3D = $head/mount_max
@onready var _camMount:Node3D = $head/camera_mount

var _pushDirection:Vector3 = Vector3()

func get_push_direction() -> Vector3:
	return _pushDirection

func get_head_transform() -> Transform3D:
	return _head.global_transform

func get_aim_point() -> Vector3:
	return _aimDot.global_position

func get_aim_collider():
	if _aimRay.is_colliding():
		return _aimRay.get_collider()
	return null

func _process(_delta:float) -> void:
	
	if _obstructionRay.is_colliding():
		_camMount.global_position = _obstructionRay.get_collision_point()
		pass
	else:
		_camMount.global_position = _camTarget.global_position
		pass
	
	if _aimRay.is_colliding():
		_aimDot.global_position = _aimRay.get_collision_point()
	else:
		var t:Transform3D = _aimRay.global_transform
		_aimDot.global_position = t.origin + (-t.basis.z * 1000)
	pass

	if Zqf.has_mouse_claims():
		_pushDirection = Vector3()
		return

	var input_dir:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	_pushDirection = (self.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func _input(event) -> void:
	if Zqf.has_mouse_claims():
		return
	var motion:InputEventMouseMotion = event as InputEventMouseMotion
	if motion == null:
		return
	var degrees:Vector3 = self.rotation_degrees
	degrees.y += (-motion.relative.x) * 0.1
	self.rotation_degrees = degrees
	
	degrees = _head.rotation_degrees
	degrees.x += (motion.relative.y) * 0.1
	_head.rotation_degrees = degrees
