#@implements IMob IActor IHittable
extends CharacterBody3D
class_name MobBase

const MOB_EVENT_DIED:String = "mob_died"

signal mob_broadcast_event(eventType, mobInstance)

@onready var _spawnInfo:MobSpawnInfo = $MobSpawnInfo
@onready var _displayRoot:Node3D = $display
@onready var _bodyDisplayRoot:Node3D = $display
@onready var _hitbox:Area3D = $hitbox
@onready var _bodyShape:CollisionShape3D = $CollisionShape3D
@onready var _thinkInfo:MobThinkInfo = $MobThinkInfo

var _healthMax:float = 1.0
var _health:float = 1.0
var _defenceStrengthMax:float = 1.0
var _defenceStrength:float = 1.0
var _defenceless:bool = false
var _parryChance:float = 0

var _power:float = 0.0
var _powerPerSecond:float = 1.0 / 20.0

var _hitBounceTick:float = 1.0
var _hitBounceTime:float = 1.0

var _hitBounceDisplayT:Transform3D
var _hitOriginDisplayT:Transform3D

var _timeSinceLastHit:float = 0.0
var _blockDamage:float = 0.0
var _unblockedDamage:float = 0.0
var _defendedHitsAccumulator:float = 0.0

func _ready() -> void:
	set_hitbox_enabled(false)
	set_world_collision_enabled(false)
	set_display_visible(false)
	_hitOriginDisplayT = _bodyDisplayRoot.transform

func set_world_collision_enabled(_flag:bool) -> void:
	_bodyShape.disabled = !_flag

func set_hitbox_enabled(_flag:bool) -> void:
	_hitbox.monitorable = _flag
	_hitbox.monitoring = _flag

func set_display_visible(_flag:bool) -> void:
	_displayRoot.visible = _flag

func _run_spawn() -> void:
	#print("MobBase run spawn")
	_health = _healthMax
	_defenceStrength = _defenceStrengthMax
	var t:Transform3D = Transform3D.IDENTITY
	t.origin = _spawnInfo.t.origin
	self.global_transform = _spawnInfo.t
	set_hitbox_enabled(true)
	set_display_visible(true)
	set_world_collision_enabled(true)

func _refresh_think_info(_delta:float) -> void:
	_thinkInfo.target = Game.get_player_target()
	if _thinkInfo.target == null:
		return
	_thinkInfo.selfGroundPos = self.global_position
	_thinkInfo.selfHeadPos = _thinkInfo.selfGroundPos
	_thinkInfo.selfHeadPos.y += 1.4

	# we're a 3D game honest
	var flatTargetPos:Vector3 = _thinkInfo.target.t.origin
	flatTargetPos.y = _thinkInfo.selfGroundPos.y
	_thinkInfo.xzTowardTarget = (flatTargetPos - _thinkInfo.selfGroundPos)

func _physics_process(_delta:float) -> void:
	_timeSinceLastHit += _delta
	_power = clampf(_power + (_powerPerSecond * _delta), 0, 1.0)
	_refresh_think_info(_delta)
	if _thinkInfo.target == null:
		return
	pass

func _exit_tree():
	self.emit_signal("mob_broadcast_event", MobBase.MOB_EVENT_DIED, self)

##################################################
# interfaces
##################################################

func get_team_id() -> int:
	return Game.TEAM_ID_ENEMY

func get_spawn_info() -> MobSpawnInfo:
	return _spawnInfo

func spawn() -> void:
	call_deferred("_run_spawn")

func get_id() -> String:
	return _spawnInfo.uuid

func teleport(_transform:Transform3D) -> void:
	self.global_position = _transform.origin
	pass

func _spawn_hit_victim_fx(damageType:int, hitPos:Vector3, hitDir:Vector3) -> void:
	var gfxPos:Vector3 = self.global_position
	gfxPos.y += 1
	gfxPos = gfxPos.lerp(hitPos, 0.5)

	var gfxDir:Vector3 = hitDir
	gfxDir.y = 0
	gfxDir = gfxDir.normalized()

	if damageType == Game.DAMAGE_TYPE_SLASH:
		var fxSpeed:float = randf_range(5, 10)
		Game.spawn_gfx_blade_blood_spurt(gfxPos, gfxDir)
		Game.gfx_blood_splat_thrown(gfxPos, ZqfUtils.quick_skew_direction(gfxDir), fxSpeed)
	elif Game.DAMAGE_TYPE_BULLET:
		var fxSpeed:float = randf_range(10, 20)
		Game.spawn_gfx_blade_blood_spurt(gfxPos, gfxDir)
		Game.gfx_blood_splat_thrown(gfxPos, ZqfUtils.quick_skew_direction(gfxDir), fxSpeed)
	else:
		var fxSpeed:float = randf_range(2, 4)
		Game.spawn_gfx_punch_blood_spurt(gfxPos)
		Game.gfx_blood_splat_thrown(gfxPos, ZqfUtils.quick_skew_direction(gfxDir), fxSpeed)

func _run_hit_bounce(hitDir:Vector3) -> void:
	_hitBounceTick = 0.0
	_hitBounceTime = _hitBounceTime
	_hitBounceDisplayT = _hitOriginDisplayT
	var bounceAxis:Vector3 = hitDir.cross(Vector3.UP).normalized()
	_hitBounceDisplayT = _hitBounceDisplayT.rotated(bounceAxis, deg_to_rad(45.0))

# Returns > 0 if hit is allowed
func check_for_hit_rejection(hitInfo) -> int:
	if hitInfo.damageTeamId == Game.TEAM_ID_ENEMY:
		return Game.HIT_VICTIM_RESPONSE_SAME_TEAM
	return 1
	

func hit(_hitInfo) -> int:
	#print("Mob dummy hit")
	if _hitInfo.damageTeamId == Game.TEAM_ID_ENEMY:
		return Game.HIT_VICTIM_RESPONSE_SAME_TEAM
	
	var inflictedDamage:float = _hitInfo.damage
	if _defenceless:
		inflictedDamage *= 2
	_health -= inflictedDamage
	
	_run_hit_bounce(_hitInfo.direction)
	_spawn_hit_victim_fx(_hitInfo.damageType, _hitInfo.position, _hitInfo.direction)


	#_hitBounceTick = 0.0
	#_hitBounceTime = _hitBounceTime
	#_hitBounceDisplayT = _hitOriginDisplayT
	#var bounceAxis:Vector3 = _hitInfo.direction.cross(Vector3.UP).normalized()
	#_hitBounceDisplayT = _hitBounceDisplayT.rotated(bounceAxis, deg_to_rad(45.0))
	
	#var gfxDir:Vector3 = _hitInfo.direction
	#gfxDir.y = 0
	#gfxDir = gfxDir.normalized()
	#var gfxPos:Vector3 = self.global_position
	#gfxPos.y += 1
	#gfxPos = gfxPos.lerp(_hitInfo.position, 0.5)
	#if _hitInfo.damageType == Game.DAMAGE_TYPE_SLASH:
	#	var fxSpeed:float = randf_range(5, 10)
	#	Game.spawn_gfx_blade_blood_spurt(gfxPos, gfxDir)
	#	Game.gfx_blood_splat_thrown(gfxPos, ZqfUtils.quick_skew_direction(gfxDir), fxSpeed)
	#elif Game.DAMAGE_TYPE_BULLET:
	#	var fxSpeed:float = randf_range(10, 20)
	#	Game.spawn_gfx_blade_blood_spurt(gfxPos, gfxDir)
	#	Game.gfx_blood_splat_thrown(gfxPos, ZqfUtils.quick_skew_direction(gfxDir), fxSpeed)
	#else:
	#	var fxSpeed:float = randf_range(2, 4)
	#	Game.spawn_gfx_punch_blood_spurt(gfxPos)
	#	Game.gfx_blood_splat_thrown(gfxPos, ZqfUtils.quick_skew_direction(gfxDir), fxSpeed)
	return 1

##################################################
# movement and orientation
##################################################
func _look_toward_flat(targetPos:Vector3) -> void:
	var selfPos:Vector3 = self.global_position
	targetPos.y = selfPos.y
	self.look_at(targetPos, Vector3.UP)

func _step_toward_flat(targetPos:Vector3, metresPerSecond:float, _delta:float) -> void:
	var selfPos:Vector3 = self.global_position
	targetPos.y = selfPos.y
	var move:Vector3 = (targetPos - selfPos).normalized() * metresPerSecond
	self.velocity = move
	self.move_and_slide()

func _slide_in_direction(dir:Vector3, metresPerSecond:float, _delta:float) -> bool:
	self.velocity = dir * metresPerSecond
	return self.move_and_slide()

##################################################
# lifetime
##################################################

func _process(_delta:float) -> void:
	_hitBounceTick += _delta
	_hitBounceTick = clampf(_hitBounceTick, 0, _hitBounceTime)
	var weight:float = _hitBounceTick / _hitBounceTime
	_bodyDisplayRoot.transform = _hitBounceDisplayT.interpolate_with(_hitOriginDisplayT, weight)
