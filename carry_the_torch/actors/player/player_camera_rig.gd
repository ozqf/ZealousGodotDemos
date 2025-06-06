extends Node3D
class_name PlayerCameraRig

@onready var _yawBase:Node3D = $yaw_base
@onready var _pitchBase:Node3D = $yaw_base/pitch_base
@onready var _flyingBase:Node3D = $flying_base
@onready var _cameraBlockRay:RayCast3D = $yaw_base/pitch_base/RayCast3D
@onready var _cameraTargetGlide:Node3D = $flying_base/camera_target
@onready var _cameraTargetFlat:Node3D = $yaw_base/pitch_base/camera_target
@onready var _cameraMount:Node3D = $camera_mount

enum RigMode { Surface, Glide }
var _mode:RigMode = RigMode.Surface

var _surfaceNormal:Vector3 = Vector3.UP
var _lastRotationTarget:Basis = Basis.IDENTITY
#var _pitchInverted:bool = true

func reset() -> void:
	self.global_position = get_parent().global_position
	_yawBase.global_transform.basis = Basis.IDENTITY
	_pitchBase.global_transform.basis = Basis.IDENTITY
	_surfaceNormal = Vector3.UP
	_lastRotationTarget = Basis.IDENTITY

func set_surface_normal(newNormal:Vector3) -> void:
	_surfaceNormal = newNormal
	#var degrees:Vector3 = _yawBase.rotation_degrees
	#degrees.z = 0
	#_yawBase.rotation_degrees = degrees
	#self.global_transform.basis = ZqfUtils.align_to_surface(self.global_transform.basis, _surfaceNormal)

func get_surface_input_basis() -> Basis:
	return _yawBase.global_transform.basis

func get_floating_input_basis() -> Basis:
	#return _lastRotationTarget
	return _flyingBase.global_transform.basis
	#return _pitchBase.global_transform.basis

func on_move_regime_change(_prev:PlayerAvatar.MoveRegime, _current:PlayerAvatar.MoveRegime) -> void:
	match _current:
		PlayerAvatar.MoveRegime.Surface:
			on_glide_to_surface()
		PlayerAvatar.MoveRegime.Gliding:
			on_surface_to_glide()
	pass

func print_rotations() -> String:
	var yawDegrees:Vector3 = _yawBase.rotation_degrees
	var pitchDegrees:Vector3 = _pitchBase.rotation_degrees
	var flyingDegrees:Vector3 = _flyingBase.rotation_degrees
	return "Yaw " + str(yawDegrees) + " Pitch " + str(pitchDegrees) + " flying " + str(flyingDegrees)

func on_surface_to_glide() -> void:
	print(str(Engine.get_physics_frames()) + "Rig: Surface to glide")
	print(str(Engine.get_physics_frames()) + print_rotations())
	_mode = RigMode.Glide
	var yawDegrees:Vector3 = _yawBase.rotation_degrees
	var pitchDegrees:Vector3 = _pitchBase.rotation_degrees
	var flyingDegrees:Vector3 = _flyingBase.rotation_degrees
	flyingDegrees.x = pitchDegrees.x
	flyingDegrees.y = yawDegrees.y
	flyingDegrees.z = 0
	_flyingBase.rotation_degrees = flyingDegrees
	pass

func on_glide_to_surface() -> void:
	print(str(Engine.get_physics_frames()) + "Rig: Glide to surface")
	print(str(Engine.get_physics_frames()) + print_rotations())
	_mode = RigMode.Surface
	var yawDegrees:Vector3 = _yawBase.rotation_degrees
	var pitchDegrees:Vector3 = _pitchBase.rotation_degrees
	var flyingDegrees:Vector3 = _flyingBase.rotation_degrees
	_yawBase.rotation_degrees = Vector3(0.0, flyingDegrees.y, 0.0)
	_pitchBase.rotation_degrees = Vector3(flyingDegrees.x, 0.0, 0.0)
	pass

func get_input_basis(isOnSurface:bool) -> Basis:
	if isOnSurface:
		return get_surface_input_basis()
	else:
		return get_floating_input_basis()
	#return _yawBase.global_transform.basis if isOnSurface else _lastRotationTarget

func _rotate_to_surface(_delta:float) -> void:
	var current:Basis = self.global_transform.basis.orthonormalized()
	#var target:Basis = current.slerp(_surfaceSnap.global_transform.basis, 0.3)
	_lastRotationTarget = ZqfUtils.align_to_surface(current, _surfaceNormal)
	#var result:Basis = current.slerp(_lastRotationTarget, 0.2)
	var result:Basis = _lastRotationTarget
	self.global_transform.basis = result

func _tick_camera(_delta) -> void:
	var targetNode:Node3D = _cameraTargetFlat
	if _mode == RigMode.Glide:
		targetNode = _cameraTargetGlide
	
	var origin:Transform3D = _cameraMount.global_transform
	var target:Transform3D = targetNode.global_transform
	# Basis must be normalized in order to be casted to a Quaternion.
	# Use get_rotation_quaternion() or call orthonormalized() if the Basis contains linearly independent vectors.
	# https://docs.godotengine.org/en/stable/tutorials/3d/using_transforms.html
	#var result:Transform3D = origin.interpolate_with(target, 0.9)
	# just snap camera since lerp is screwed up
	var result:Transform3D = target
	_cameraMount.global_transform = result
	# move the camera on its 'track' if blocked
	#if !_cameraBlockRay.is_colliding():
	#	_cameraMountFlat.position = _cameraTargetFlat.position
	#else:
	#	_cameraMountFlat.global_position = _cameraBlockRay.get_collision_point()
	pass

func _physics_process(_delta:float) -> void:
	#self.global_transform.basis = ZqfUtils.align_to_surface(self.global_transform.basis, _surfaceNormal)
	_rotate_to_surface(_delta)
	_tick_camera(_delta)
	
	# move the whole rig to chase down the player
	var chasePosCurrent:Vector3 = self.global_position
	var chasePosTarget:Vector3 = get_parent().global_position
	self.global_position = chasePosCurrent.lerp(chasePosTarget, 0.9)
	pass

func apply_surface_yaw(degreesYaw:float) -> void:
	var axis:Vector3 = _yawBase.basis.y.normalized()
	_yawBase.rotate(axis, degreesYaw * ZqfUtils.DEG2RAD)

func apply_surface_pitch(degreesPitch:float) -> void:
	var axis:Vector3 = _pitchBase.basis.x.normalized()
	_pitchBase.rotate(axis, degreesPitch * ZqfUtils.DEG2RAD)

func apply_gliding_pitch(degreesPitch:float) -> void:
	var axis:Vector3 = _flyingBase.basis.x.normalized()
	_flyingBase.rotate(axis, degreesPitch * ZqfUtils.DEG2RAD)
	#var axis:Vector3 = _yawBase.basis.x.normalized()
	#_yawBase.rotate(axis, degreesPitch * ZqfUtils.DEG2RAD)

func apply_gliding_roll(degreesPitch:float) -> void:
	var axis:Vector3 = _flyingBase.basis.z.normalized()
	_flyingBase.rotate(axis, degreesPitch * ZqfUtils.DEG2RAD)
	# var axis:Vector3 = _yawBase.basis.z.normalized()
	# _yawBase.rotate(axis, degreesPitch * ZqfUtils.DEG2RAD)
