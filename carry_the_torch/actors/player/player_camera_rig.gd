extends Node3D
class_name PlayerCameraRig

@onready var _yawBase:Node3D = $yaw_base
@onready var _pitchBase:Node3D = $yaw_base/pitch_base
@onready var _cameraBlockRay:RayCast3D = $yaw_base/pitch_base/RayCast3D
@onready var _cameraTarget:Node3D = $yaw_base/pitch_base/camera_target
@onready var _cameraMount:Node3D = $yaw_base/pitch_base/camera_mount

var _surfaceNormal:Vector3 = Vector3(0, 1, 0)
var _pitchInverted:bool = true

func set_surface_normal(newNormal:Vector3) -> void:
	_surfaceNormal = newNormal
	self.global_transform.basis = ZqfUtils.align_to_surface(self.global_transform.basis, _surfaceNormal)

func get_surface_input_basis() -> Basis:
	return _yawBase.global_transform.basis

func get_floating_input_basis() -> Basis:
	return _pitchBase.global_transform.basis

func _process(_delta:float) -> void:
	# move the camera on its 'track' if blocked
	if !_cameraBlockRay.is_colliding():
		_cameraMount.position = _cameraTarget.position
	else:
		_cameraMount.global_position = _cameraBlockRay.get_collision_point()
	
	# move the whole rig to chase down the player
	var chasePosCurrent:Vector3 = self.global_position
	var chasePosTarget:Vector3 = get_parent().global_position
	self.global_position = chasePosCurrent.lerp(chasePosTarget, 0.9)
	pass

func apply_yaw_rotation(degreesYaw:float) -> void:
	_yawBase.rotate(_yawBase.basis.y, degreesYaw * ZqfUtils.DEG2RAD)

func apply_pitch_rotation(degreesPitch:float) -> void:
	_pitchBase.rotate(_pitchBase.basis.x, degreesPitch * ZqfUtils.DEG2RAD)

func on_input(event) -> void:
	if Game.has_mouse_claims():
		return
	var motion:InputEventMouseMotion = event as InputEventMouseMotion
	if motion == null:
		return
	
	var degreesYaw:float = (-motion.relative.x) * 0.2
	var degreesPitch:float = (-motion.relative.y) * 0.2
	# inverted
	if _pitchInverted:
		degreesPitch = -degreesPitch
	_yawBase.rotate(_yawBase.basis.y, degreesYaw * ZqfUtils.DEG2RAD)
	_pitchBase.rotate(_pitchBase.basis.x, degreesPitch * ZqfUtils.DEG2RAD)
