extends Node3D
class_name GameController

const TEAM_ID_NONE:int = 0
const TEAM_ID_ENEMY:int = 1
const TEAM_ID_PLAYER:int = 2

var _titleType:PackedScene = preload("res://worlds/title/title.tscn")
var _sandboxWorldType:PackedScene = preload("res://worlds/sandbox/sandbox.tscn")
var _gameWorldType:PackedScene = preload("res://worlds/01/01.tscn")

var _playerType:PackedScene = preload("res://actors/player/player_avatar.tscn")
var _targetDummyType:PackedScene = preload("res://actors/mobs/target_dummy.tscn")
var _wallTurretType:PackedScene = preload("res://actors/world/wall_turret.tscn")
var _volumeTriggerType:PackedScene = preload("res://actors/volumes/trigger_volume.tscn")

@onready var _emptyTarget:ActorTargetInfo = $empty_target
@onready var _player:PlayerAvatar = null
@onready var _rootMenu:RootMenu = $RootMenu
var _spawnPoints:Dictionary = {}

func _ready():
	call_deferred("start_title")
	add_to_group(Zqf.GROUP_APP)

func on_app_event(_event:String) -> void:
	match _event:
		Zqf.APP_EVENT_PAUSE:
			Engine.time_scale = 0.0
		Zqf.APP_EVENT_PLAY:
			Engine.time_scale = 1.0

func register_player(plyr:PlayerAvatar) -> void:
	_player = plyr

func get_player_target() -> ActorTargetInfo:
	if _player != null:
		return _player.get_target_info()
	return _emptyTarget

func register_spawn_point(uuid:String, spawnPoint) -> void:
	print("Register spawn " + uuid)
	_spawnPoints[uuid] = spawnPoint

func unregister_spawn_point(uuid:String) -> void:
	print("Unregister spawn " + uuid)
	_spawnPoints.erase(uuid)

func get_spawn_point(uuid:String):
	if !_spawnPoints.has(uuid):
		return null
	return _spawnPoints[uuid]

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

func start_new_game() -> void:
	print("===== start game =====")
	_spawn_world(_gameWorldType)

func start_title() -> void:
	print("===== start title =====")
	_spawn_world(_titleType)

func start_gym() -> void:
	print("===== start gym =====")
	_spawn_world(_sandboxWorldType)

func _spawn_world(worldType:PackedScene) -> void:
	Zqf.clear_all_actors()
	var world:Node3D = Zqf.create_new_world(worldType)
	var spawnList:Array = _gather_spawn_list(world)
	_spawn_actors(spawnList)

func _spawn_actors(list:Array) -> void:
	Zqf.clear_all_actors()
	
	var numActors:int = list.size()
	print("Spawning " + str(numActors) + " actors")
	for i in range(0, numActors):
		var data:Dictionary = list[i]
		restore_actor(data)

func _spawn_player(t:Transform3D) -> void:
	var plyr:Node3D = Zqf.create_actor(_playerType)
	plyr.global_transform = t

func restore_actor(data:Dictionary) -> String:
	var type:String = data.meta.prefab
	if !data.meta.has("uuid") || data.meta.uuid == "":
		data.meta.uuid = UUID.v4()
	var newUUID:String = data.meta.uuid

	print("Restoring " + str(type))
	match type:
		"player_start":
			var t:Transform3D = ZqfUtils.Transform3D_from_dict(data.xform)
			_spawn_player(t)
		"target_dummy":
			var dummy = Zqf.create_actor(_targetDummyType)
			dummy.global_transform = ZqfUtils.Transform3D_from_dict(data.xform)
		"wall_turret":
			var turret = Zqf.create_actor(_wallTurretType)
			turret.global_transform = ZqfUtils.Transform3D_from_dict(data.xform)
		"trigger_volume":
			var vol = Zqf.create_actor(_volumeTriggerType)
			vol.restore(data)
		_:
			print("Unknown actor type " + str(type))
			return ""
	print("Spawned new " + str(type) + " " + str(newUUID))
	return newUUID

func _process(_delta):
	if Input.is_action_just_pressed("toggle_console"):
		if _rootMenu.is_on():
			_rootMenu.off()
		else:
			_rootMenu.on()
	pass
