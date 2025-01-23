extends Node3D
class_name GameController

const TEAM_ID_NONE:int = 0
const TEAM_ID_ENEMY:int = 1
const TEAM_ID_PLAYER:int = 2

var _worldType:PackedScene = preload("res://worlds/sandbox/sandbox.tscn")
var _playerType:PackedScene = preload("res://actors/player/player_avatar.tscn")
var _targetDummyType:PackedScene = preload("res://actors/target_dummy/target_dummy.tscn")
var _wallTurretType:PackedScene = preload("res://actors/world/wall_turret.tscn")
var _volumeTriggerType:PackedScene = preload("res://actors/volumes/trigger_volume.tscn")

@onready var _emptyTarget:ActorTargetInfo = $empty_target
@onready var _player:PlayerAvatar = null

func _ready():
	call_deferred("_spawn_world")

func register_player(plyr:PlayerAvatar) -> void:
	_player = plyr

func get_player_target() -> ActorTargetInfo:
	if _player != null:
		return _player.get_target_info()
	return _emptyTarget

func _find_actor_proxies(root:Node, results:Array) -> void:
	if root.has_method("get_actor_proxy_info"):
		results.push_back(root)
	for node in root.get_children():
		_find_actor_proxies(node, results)

func _gather_spawn_list(world:Node) -> Array:
	var proxies:Array = []
	_find_actor_proxies(world, proxies)
	print("Found " + str(proxies.size()) + " proxies")
	var spawnList:Array = []
	for proxy in proxies:
		if !proxy.has_method("get_spawn_data"):
			print("Node " + proxy.name + " is not a proxy...")
			continue
		var data:Dictionary = proxy.get_spawn_data()
		if data.is_empty():
			print("Node " + proxy.name + " provided empty spawn data")
			continue
		proxy.visible = false
		spawnList.push_back(data)
	return spawnList

func _spawn_world() -> void:
	var world:Node3D = Zqf.create_new_world(_worldType)
	var spawnList:Array = _gather_spawn_list(world)
	_spawn_actors(spawnList)

func _spawn_actors(list:Array) -> void:
	Zqf.clear_all_actors()
	
	var numActors:int = list.size()
	print("Spawning " + str(numActors) + " actors")
	for i in range(0, numActors):
		var data:Dictionary = list[i]
		_restore_actor(data)

func _spawn_player(t:Transform3D) -> void:
	var plyr:Node3D = _playerType.instantiate() as Node3D
	Zqf.get_actor_root().add_child(plyr)
	plyr.global_transform = t

func _restore_actor(data:Dictionary) -> void:
	var type:String = data.meta.prefab
	print("Restoring " + str(type))
	match type:
		"player_start":
			var t:Transform3D = ZqfUtils.Transform3D_from_dict(data.xform)
			_spawn_player(t)
		#"target_dummy":
		#	var dummy = Zqf.create_actor(_targetDummyType)
		#	dummy.global_transform = ZqfUtils.Transform3D_from_dict(data.xform)
		"wall_turret":
			var turret = Zqf.create_actor(_wallTurretType)
			turret.global_transform = ZqfUtils.Transform3D_from_dict(data.xform)
		"trigger_volume":
			var vol = Zqf.create_actor(_volumeTriggerType)
			vol.restore(data)
		_:
			print("Unknown actor type " + str(type))
