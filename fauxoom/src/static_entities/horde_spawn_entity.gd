# simple entity wrapper for a horde spawner
extends Spatial

var _prefab_mob_punk = preload("res://prefabs/dynamic_entities/mob_punk.tscn")
var _prefab_mob_gunner = preload("res://prefabs/dynamic_entities/mob_gunner.tscn")

# onready var _spawner:HordeSpawnComponent = $logic
onready var _ent:Entity = $Entity

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
	var _r = _ent.connect("entity_append_state", self, "append_state")
	_r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_trigger", self, "on_trigger")
	_ent.selfName = triggerName
	_ent.triggerTargetName = triggerTargetName

func append_state(_dict:Dictionary) -> void:
	_dict.liveMobs = _liveMobs
	_dict.deadMobs = _deadMobs
	_dict.tick = _tick
	_dict.active = _active

func restore_state(_dict:Dictionary) -> void:
	_liveMobs = _dict.liveMobs
	_deadMobs = _dict.deadMobs
	_tick = _dict.tick
	_active = _dict.active

func on_trigger() -> void:
	print("Horde spawn start")
	_active = true

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

func set_spawn_points(newTransformsArray) -> void:
	_spawnPoints = newTransformsArray

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
	mob.set_source(self, _ent.id)
	# mob.connect("on_mob_died", self, "_on_mob_died")

func _on_mob_died(_mob) -> void:
	_liveMobs -= 1
	_deadMobs += 1
	# print("Mob death: " + str(_deadMobs) + " dead vs " + str(totalMobs) + " max")
	if _deadMobs >= totalMobs:
		_active = false
		# print("Horde spawn - all children dead")
		if triggerTargetName != "":
			Interactions.triggerTargets(get_tree(), triggerTargetName)
