extends Node
class_name GameMain

const GROUP_GAME_EVENTS:String = "game_events"
const GAME_EVENT_FN_PLAYER_SPAWNED:String = "game_event_player_spawned"
const GAME_EVENT_FN_PLAYER_DESPAWNED:String = "game_event_player_despawned"

const GROUP_TRIGGER_EVENTS:String = "trigger_events"
# params: (targetIds:PackedStringArray, eventType:String, data:Dictionary)
const TRIGGER_EVENT_FN_TRIGGER:String = "trigger_event"

const TEAM_ID_NONE:int = 0
const TEAM_ID_ENEMY:int = 1
const TEAM_ID_PLAYER:int = 2

const DAMAGE_TYPE_SLASH:int = 0
const DAMAGE_TYPE_PUNCH:int = 1
const DAMAGE_TYPE_BULLET:int = 2

const HIT_RESPONSE_SAME_TEAM:int = -1
const HIT_RESPONSE_PARRIED:int = -2
const HIT_RESPONSE_BLOCKED:int = -3

# dto types
var _targetInfoType = preload("res://shared/info/target_info.gd")
var _hitInfoType = preload("res://shared/info/hit_info.gd")

# player
var _playerAvatarType = preload("res://actors/player/player_avatar.tscn")

# mob types
var _mobDummyType = preload("res://actors/mobs/dummy/mob_dummy.tscn")
var _mobFodderType = preload("res://actors/mobs/fodder/mob_fodder.tscn")

# projectile types
var _prjBasicType = preload("res://actors/projectiles/basic/prj_basic.tscn")

# gfx types
var _gfxBladeBloodSpurtType = preload("res://gfx/blade_blood_spurt/gfx_blade_blood_spurt.tscn")
var _gfxPunchBloodSpurtType = preload("res://gfx/punch_blood_spurt/gfx_punch_blood_spurt.tscn")
var _gfxEjectedShellType = preload("res://gfx/ejected_brass/ejected_shell.tscn")
var _gfxBlasterMuzzleType = preload("res://gfx/blaster/gfx_blaster_muzzle.tscn")
var _gfxBloodSplatThrownType = preload("res://gfx/splats/decal_blood_splat_01.tscn")
var _gfxParryImpactType = preload("res://gfx/parry_impact/gfx_parry_impact.tscn")
var _gfxMeleeWhiff = preload("res://gfx/melee_hit_whiff/melee_hit_whiff.tscn")

var _sandboxWorld:PackedScene = preload("res://worlds/sandbox/sandbox.tscn")

@onready var _worldRoot:Node3D = $world_root
@onready var sound:GameSound = $GameSound

var _avatar:PlayerAvatar = null

func _ready():
	self.add_to_group(GROUP_GAME_EVENTS)
	var world = _sandboxWorld.instantiate()
	_worldRoot.add_child(world)

####################################################
# DTOs
####################################################

func new_target_info() -> TargetInfo:
	return _targetInfoType.new()

func new_hit_info() -> HitInfo:
	return _hitInfoType.new()

####################################################
# spawning
####################################################

func spawn_player_avatar(t:Transform3D) -> PlayerAvatar:
	var plyr = _playerAvatarType.instantiate() as PlayerAvatar
	_worldRoot.add_child(plyr)
	plyr.global_position = t.origin
	return plyr

func spawn_mob_dummy() -> Node3D:
	var mob = _mobDummyType.instantiate() as Node3D
	_worldRoot.add_child(mob)
	return mob

func spawn_mob_fodder() -> Node3D:
	var mob = _mobFodderType.instantiate() as Node3D
	_worldRoot.add_child(mob)
	return mob

func spawn_gfx_blade_blood_spurt(pos:Vector3, forward:Vector3) -> Node3D:
	#print("gfx pos " + str(pos) + " forward" + str(forward))
	var gfx:GPUParticles3D = _gfxBladeBloodSpurtType.instantiate() as GPUParticles3D
	_worldRoot.add_child(gfx)
	gfx.global_position = pos
	gfx.look_at(pos + forward, Vector3.UP)
	gfx.emitting = true
	return gfx

func spawn_gfx_blaster_muzzle(pos:Vector3, forward:Vector3) -> Node3D:
	var gfx:Node3D = _gfxBlasterMuzzleType.instantiate() as Node3D
	_worldRoot.add_child(gfx)
	gfx.global_position = pos
	gfx.look_at(pos + forward, Vector3.UP)
	return gfx

func spawn_gfx_punch_blood_spurt(pos:Vector3) -> Node3D:
	var gfx:Node3D = _gfxPunchBloodSpurtType.instantiate() as Node3D
	_worldRoot.add_child(gfx)
	gfx.global_position = pos
	return gfx

func spawn_prj_basic() -> PrjBasic:
	var prj = _prjBasicType.instantiate() as PrjBasic
	_worldRoot.add_child(prj)
	return prj

func spawn_gfx_ejected_shell(pos:Vector3, forward:Vector3) -> void:
	var gfx:Node3D = _gfxEjectedShellType.instantiate() as RigidBody3D
	_worldRoot.add_child(gfx)
	gfx.global_position = pos
	gfx.linear_velocity = (forward * 10)

func gfx_blood_splat_thrown(pos:Vector3, forward:Vector3, speed:float = 10) -> void:
	var gfx:DecalThrownBloodSplat = _gfxBloodSplatThrownType.instantiate() as DecalThrownBloodSplat
	_worldRoot.add_child(gfx)
	gfx.throw_decal(pos, forward, speed)

func gfx_parry_impact(pos:Vector3) -> void:
	var gfx:Node3D = _gfxParryImpactType.instantiate()
	_worldRoot.add_child(gfx)
	gfx.global_position = pos

func gfx_melee_hit_whiff(pos:Vector3) -> void:
	var gfx:Node3D = _gfxMeleeWhiff.instantiate()
	_worldRoot.add_child(gfx)
	gfx.global_position = pos

####################################################
# registers
####################################################

func game_event_player_spawned(plyr:PlayerAvatar) -> void:
	_avatar = plyr

func game_event_player_despawned(plyr:PlayerAvatar) -> void:
	_avatar = null

####################################################
# interactions
####################################################
func try_hit(_hitInfo:HitInfo, hitbox:Area3D) -> int:
	if hitbox.has_method("hit"):
		return hitbox.hit(_hitInfo)
	return -1

func broadcast_trigger_event(targetIds:PackedStringArray, eventType:String, data:Dictionary) -> void:
	var grp:String = GROUP_TRIGGER_EVENTS
	var fn:String = TRIGGER_EVENT_FN_TRIGGER
	get_tree().call_group(grp, fn, targetIds, eventType, data)

####################################################
# queries
####################################################
func get_player_target() -> TargetInfo:
	if _avatar != null:
		return _avatar.get_target_info()
	return null
