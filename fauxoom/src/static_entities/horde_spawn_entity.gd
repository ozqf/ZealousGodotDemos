# simple entity wrapper for a horde spawner
extends Spatial

var _prefab_mob_punk = preload("res://prefabs/dynamic_entities/mob_punk.tscn")
var _prefab_mob_gunner = preload("res://prefabs/dynamic_entities/mob_gunner.tscn")

onready var _spawner:HordeSpawnComponent = $logic
onready var _ent:Entity = $Entity

export var triggerName:String = ""
export var triggerTargetName:String = ""

export var childType:int = 1
export var tickMax:float = 2
export var totalMobs:int = 4
export var maxLiveMobs:int = 2

func _ready() -> void:
	visible = false
	var _r = _ent.connect("entity_append_state", self, "append_state")
	_r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_trigger", self, "on_trigger")
	_spawner.childType = childType
	_spawner.tickMax = tickMax
	_spawner.totalMobs = totalMobs
	_spawner.maxLiveMobs = maxLiveMobs
	_ent.selfName = triggerName
	_ent.triggerTargetName = triggerTargetName

func append_state(_dict:Dictionary) -> void:
	_spawner.append_state(_dict)

func restore_state(_dict:Dictionary) -> void:
	_spawner.restore_state(_dict)

func on_trigger() -> void:
	_spawner.start()
