extends Spatial
class_name MobSpawnProxy

const Enums = preload("res://src/enums.gd")

signal trigger()

onready var _ent:Entity = $Entity

export(Enums.EnemyType) var type = Enums.EnemyType.Punk
export var delaySpawn:bool = false
export var spawnAlert:bool = false
export var sniper:bool = false

var _used:bool = false
var _prefabName:String = "mob_punk"
var _childId:int = 0

func _ready() -> void:
	visible = false
	add_to_group(Groups.GAME_GROUP_NAME)
	var _result = _ent.connect("entity_append_state", self, "append_state")
	_result = _ent.connect("entity_restore_state", self, "restore_state")
	_result = _ent.connect("entity_trigger", self, "on_trigger")

func game_run_map_spawns() -> void:
	if !delaySpawn:
		on_trigger()

func append_state(_dict:Dictionary) -> void:
	_dict.used = _used

func restore_state(_dict:Dictionary) -> void:
	_used = _dict.used

func _on_mob_died(_mob) -> void:
	# print("Spawn proxy saw child die")
	emit_signal("trigger")

# func _select_prefab(enemyType:int) -> String:
# 	if enemyType == EnemyType.FleshWorm:
# 		return Entities.PREFAB_MOB_WORM
# 	elif enemyType == EnemyType.Spider:
# 		return Entities.PREFAB_MOB_SPIDER
# 	else:
# 		return Entities.PREFAB_MOB_PUNK

func on_trigger() -> void:
	if _used:
		return
	# spawn mob
	_used = true
	# print("Proxy spawning mob type " + str(type))
	var mob = Ents.create_mob(type, global_transform, spawnAlert)
	_childId = mob.get_node("Entity").id
	# print("Spawned mob Id " + str(_childId))
	mob.set_source(self, _ent.id)
	mob.set_behaviour(sniper)
