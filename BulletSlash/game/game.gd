extends Node
class_name GameMain

const GROUP_GAME_EVENTS:String = "game_events"
const GAME_EVENT_FN_PLAYER_SPAWNED:String = "game_event_player_spawned"
const GAME_EVENT_FN_PLAYER_DESPAWNED:String = "game_event_player_despawned"

# dto types
var _targetInfoType = preload("res://dtos/target_info.gd")
var _hitInfoType = preload("res://dtos/hit_info.gd")

# mob types
var _mobFodderType = preload("res://actors/mobs/fodder/mob_fodder.tscn")

var _sandboxWorld:PackedScene = preload("res://worlds/sandbox/sandbox.tscn")

@onready var _worldRoot:Node3D = $world_root

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

func spawn_mob_fodder() -> Node3D:
	var mob = _mobFodderType.instantiate() as Node3D
	_worldRoot.add_child(mob)
	return mob

####################################################
# registers
####################################################

func game_event_player_spawned(plyr:PlayerAvatar) -> void:
	_avatar = plyr

func game_event_player_despawned(plyr:PlayerAvatar) -> void:
	_avatar = null

####################################################
# queries
####################################################
func get_player_target() -> TargetInfo:
	if _avatar != null:
		return _avatar.get_target_info()
	return null
