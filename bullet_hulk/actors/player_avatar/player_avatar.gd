extends CharacterBody3D
class_name PlayerAvatar

const SPRINT_SPEED:float = 8
const RUN_SPEED:float = 5
const WALK_SPEED:float = 4

const SPIN_UP_TIME:float = 1.5
const SPIN_DOWN_TIME:float = 3.0

@onready var _yaw:Node3D = $yaw
@onready var _pitch:Node3D = $yaw/pitch
@onready var _hitscanSource:Node3D = $yaw/pitch/hitscan_node
@onready var _weaponLaunchSource:Node3D = $yaw/pitch/weapon/weapon_launch_node
@onready var _atkInfo:AttackInfo = $AttackInfo
@onready var _rotor:Node3D = $yaw/pitch/weapon/rotor
@onready var _muzzleFlashLight:OmniLight3D = $yaw/pitch/muzzle_flash_light
@onready var _upperBodyShape:CollisionShape3D = $upper_body_shape
@onready var _headRoomArea:Area3D = $headroom_area

var _hitscan:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()

var _fireTick:float = 0.0
var _spinWeight:float = 0.0
var _muzzleFlashTick:float = 0.0
var _crouching:bool = false
var _sprinting:bool = false
var _standingPitchPos:Vector3 = Vector3()
var _crouchedPitchPos:Vector3 = Vector3()

func _ready() -> void:
	self.add_to_group(Game.GROUP_GLOBAL_EVENTS)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_hitscan.exclude = [self]
	_standingPitchPos = _pitch.position
	_crouchedPitchPos = _standingPitchPos - Vector3(0, 1, 0)

func global_event(msg:String):
	match msg:
		Game.GLOBAL_EVENT_END_OF_LEVEL:
			self.queue_free()

func refresh_target_info() -> void:
	var info:TargetInfo = Game.get_target()
	info.t = _yaw.global_transform
	info.headT = _pitch.global_transform
	info.age = 0

func _fire_hitscan() -> void:
	var t:Transform3D = _hitscanSource.global_transform
	#var srcT:Transform3D = t
	
	# spread is broken :/
	#var spreadDegrees:float = 2.5
	#var sx:float = randf_range(-spreadDegrees, spreadDegrees)
	#var sy:float = randf_range(-spreadDegrees, spreadDegrees)
	#t = t.rotated(t.basis.y, deg_to_rad(sy))
	#t = t.rotated(t.basis.x, deg_to_rad(sx))
	
	_hitscan.from = t.origin
	_hitscan.to = t.origin + ((-t.basis.z) * 1000)
	_hitscan.collision_mask = Interactions.get_hitscan_mask()
	_hitscan.collide_with_areas = true
	_hitscan.collide_with_bodies = true
	var fxEnd:Vector3 = _hitscan.to
	var space:PhysicsDirectSpaceState3D = self.get_world_3d().direct_space_state
	var result:Dictionary = space.intersect_ray(_hitscan)
	if !result.is_empty():
		fxEnd = result.position
		var i:int = Interactions.try_hurt(_atkInfo, result.collider)
		if i > 0:
			var impact:Node3D = Game.gfx_impact_bullet(fxEnd)
			impact.look_at(fxEnd + result.normal)
		else:
			Game.gfx_impact_bullet_world(fxEnd)
	_muzzleFlashLight.visible = true
	_muzzleFlashTick = 0.2
	_muzzleFlashLight.omni_range = randf_range(2, 5)
	var tracer:GFXTracer = Game.gfx_tracer()
	tracer.launch_tracer(_weaponLaunchSource.global_position, fxEnd)

func _has_head_room() -> bool:
	var hasOverlaps:bool = _headRoomArea.has_overlapping_bodies()
	return !hasOverlaps

func _enter_crouch() -> void:
	_crouching = true
	_upperBodyShape.disabled = true
	_pitch.position = _crouchedPitchPos

func _exit_crouch() -> void:
	_crouching = false
	_upperBodyShape.disabled = false
	_pitch.position = _standingPitchPos

func _enter_sprint() -> void:
	_sprinting = true

func _exit_sprint() -> void:
	_sprinting = false

func _physics_process(delta: float) -> void:
	refresh_target_info()
	
	###########################################
	# weapons
	###########################################
	var atkOn:bool = Input.is_action_pressed("attack_1") && !_sprinting
	if atkOn:
		_spinWeight += (1.0 / SPIN_UP_TIME) * delta
	else:
		_spinWeight -= (1.0 / SPIN_DOWN_TIME) * delta
	_spinWeight = clampf(_spinWeight, 0.0, 1.0)
	
	_spin_barrels(delta, _spinWeight)
	
	_fireTick -= delta
	_muzzleFlashTick -= delta
	if _muzzleFlashTick <= 0.0:
		_muzzleFlashLight.visible = false
	
	if atkOn && _fireTick <= 0.0:
		_fireTick = lerpf(0.3, 0.05, _spinWeight)
		_fire_hitscan()
	
	###########################################
	# movement
	###########################################
	
	var v:Vector3 = self.velocity
	v += Vector3(0, -20, 0) * delta
	
	if is_on_floor():
		if Input.is_action_just_pressed("move_up") && v.y < 6 && _has_head_room():
			v.y = 6
			_exit_crouch()
		else:
			if _crouching:
				if !Input.is_action_pressed("move_down") && _has_head_room():
					_exit_crouch()
			else:
				if Input.is_action_pressed("move_down"):
					_exit_sprint()
					_enter_crouch()
				else:
					if !_sprinting && Input.is_action_pressed("move_special"):
						_enter_sprint()
					elif _sprinting && !Input.is_action_pressed("move_special"):
						_exit_sprint()
	
	#var runSpeed:float = SPRINT_SPEED if _sprinting else RUN_SPEED
	var input:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if _sprinting:
		input.y = -1
	
	if input.is_zero_approx():
		v.x *= 0.8
		v.z *= 0.8
	else:
		var push:Vector3 = input_to_push_vector_flat(input, _yaw.basis)
		var y:float = v.y
		v.y = 0
		v += push * 150 * delta
		#var maxSpd:float = WALK_SPEED if _spinWeight > 0.5 else runSpeed # weight speed by spin rate - disallows quick dashing
		var maxSpd:float = SPRINT_SPEED if _sprinting else WALK_SPEED
		v = v.limit_length(maxSpd)
		v.y = y
	
	self.velocity = v
	self.move_and_slide()

func _spin_barrels(delta:float, weight:float) -> void:
	var degPerSecond:float = 1420 * weight
	var rot:Vector3 = _rotor.rotation_degrees
	rot.z += degPerSecond * delta
	_rotor.rotation_degrees = rot

func _input(event:InputEvent) -> void:
	var motion:InputEventMouseMotion = event as InputEventMouseMotion
	if motion == null:
		return
	
	var ratio:Vector2 = get_window_to_screen_ratio()
	var _pitchInverted:bool = true
	var degreesYaw:float = (-motion.relative.x) * 0.2 * ratio.y
	var degreesPitch:float = (-motion.relative.y) * 0.2 * ratio.x
	if _pitchInverted:
		degreesPitch = -degreesPitch
	
	var rot:Vector3 = _yaw.rotation_degrees
	rot.y += degreesYaw
	_yaw.rotation_degrees = rot

	rot = _pitch.rotation_degrees
	rot.x += degreesPitch
	rot.x = clampf(rot.x, -89, 89)
	_pitch.rotation_degrees = rot

static func input_to_push_vector_flat(input:Vector2, _basis:Basis) -> Vector3:
	var pushDir:Vector3 = (_basis * Vector3(input.x, 0, input.y)).normalized()
	return pushDir

static func get_window_to_screen_ratio(windowIndex:int = 0) -> Vector2:
	var screen:Vector2 = DisplayServer.screen_get_size()
	var window:Vector2 = DisplayServer.window_get_size(windowIndex)
	var result:Vector2 = Vector2(window.x / screen.x, window.y / screen.y)
	return result
