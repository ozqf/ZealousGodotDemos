extends CharacterBody3D
class_name PlayerAvatar

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

var _hitscan:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()

var _fireTick:float = 0.0
var _spinWeight:float = 0.0

var _muzzleFlashTick:float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_hitscan.exclude = [self]

func refresh_target_info() -> void:
	var info:TargetInfo = Game.get_target()
	info.t = _yaw.global_transform
	info.headT = _pitch.global_transform

func _fire_hitscan() -> void:
	var t:Transform3D = _hitscanSource.global_transform
	var spreadDegrees:float = 2.5
	var sx:float = randf_range(-spreadDegrees, spreadDegrees)
	var sy:float = randf_range(-spreadDegrees, spreadDegrees)
	t = t.rotated(t.basis.y, deg_to_rad(sy))
	t = t.rotated(t.basis.x, deg_to_rad(sx))
	_hitscan.from = t.origin
	_hitscan.to = t.origin + ((-t.basis.z) * 1000)
	_hitscan.collision_mask = 1
	_hitscan.collide_with_areas = true
	_hitscan.collide_with_bodies = true
	var fxEnd:Vector3 = _hitscan.to
	var space:PhysicsDirectSpaceState3D = self.get_world_3d().direct_space_state
	var result:Dictionary = space.intersect_ray(_hitscan)
	if !result.is_empty():
		fxEnd = result.position
		Game.gfx_impact_bullet(fxEnd)
		var i:int = Interactions.try_hurt(_atkInfo, result.collider)
		if i > 0:
			print("Hit!")
	_muzzleFlashLight.visible = true
	_muzzleFlashTick = 0.2
	var tracer:GFXTracer = Game.gfx_tracer()
	tracer.launch_tracer(_weaponLaunchSource.global_position, fxEnd)

func _physics_process(delta: float) -> void:
	refresh_target_info()
	
	var atkOn:bool = Input.is_action_pressed("attack_1")
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
	
	var input:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	if input.is_zero_approx():
		self.velocity *= 0.8
	else:
		var push:Vector3 = input_to_push_vector_flat(input, _yaw.basis)
		var v:Vector3 = self.velocity
		var y:float = v.y
		y = 0
		v += push * 150 * delta
		v = v.limit_length(WALK_SPEED)
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

static func input_to_push_vector_flat(input:Vector2, basis:Basis) -> Vector3:
	var pushDir:Vector3 = (basis * Vector3(input.x, 0, input.y)).normalized()
	return pushDir

static func get_window_to_screen_ratio(windowIndex:int = 0) -> Vector2:
	var screen:Vector2 = DisplayServer.screen_get_size()
	var window:Vector2 = DisplayServer.window_get_size(windowIndex)
	var result:Vector2 = Vector2(window.x / screen.x, window.y / screen.y)
	return result
