extends Spatial
class_name HordeSpawnComponent

signal spawn()

var _prefab_mob_punk = preload("res://prefabs/dynamic_entities/mob_punk.tscn")
var _prefab_mob_gunner = preload("res://prefabs/dynamic_entities/mob_gunner.tscn")

export var triggerName:String = ""
export var triggerTargetName:String = ""

export var childType:int = 1
export var tickMax:float = 2
export var totalMobs:int = 4
export var maxLiveMobs:int = 2

var _spawnPoints = []

var _liveMobs:int = 0
var _deadMobs:int = 0
var _tick:float = 0
var _active:bool = false
var sourceId:int = 0

func _ready() -> void:
	visible = false

func append_state(_dict:Dictionary) -> void:
	_dict.liveMobs = _liveMobs
	_dict.deadMobs = _deadMobs
	_dict.tick = _tick
	_dict.active = _active

func write_state() -> Dictionary:
	var dict = {}
	append_state(dict)
	return dict

func restore_state(data:Dictionary) -> void:
	_liveMobs = data.liveMobs
	_deadMobs = data.deadMobs
	_tick = data.tick
	_active = data.active

func _process(_delta:float) -> void:
	if !_active:
		return
	var consumed = _deadMobs + _liveMobs
	if (_liveMobs < maxLiveMobs) && (consumed < totalMobs):
		_tick -= _delta
		if _tick <= 0:
			_tick = tickMax
			_liveMobs += 1
			_spawn_child()

func start() -> void:
	_active = true

func set_spawn_points(newTransformsArray) -> void:
	_spawnPoints = newTransformsArray

func on_trigger_entities(name:String) -> void:
	# print("Horde spawn saw trigger name " + name + " vs self name " + triggerName)
	if name == "":
		return
	if name == triggerName:
		_active = !_active

func pick_spawn_point() -> Transform:
	var numPoints:int = _spawnPoints.size()
	if numPoints == 0:
		return self.global_transform
	else:
		var _i:int = int(rand_range(0, numPoints))
		return _spawnPoints[_i]

func _spawn_child() -> void:
	var mob = _prefab_mob_punk.instance()
	Game.get_dynamic_parent().add_child(mob)
	# mob.global_transform = pick_spawn_point()
	mob.teleport(pick_spawn_point())
	mob.force_awake()
	# no id to set this way since this isn't an entity!
	# mob.sourceId = _ent.id
	mob.connect("on_mob_died", self, "_on_mob_died")

func _on_mob_died(_mob) -> void:
	_liveMobs -= 1
	_deadMobs += 1
	# print("Mob death: " + str(_deadMobs) + " dead vs " + str(totalMobs) + " max")
	if _deadMobs >= totalMobs:
		_active = false
		# print("Horde spawn - all children dead")
		if triggerTargetName != "":
			Interactions.triggerTargets(get_tree(), triggerTargetName)
