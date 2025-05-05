extends Node3D
class_name MobSpawnProxy

const Enums = preload("res://src/enums.gd")

signal trigger()

@onready var _ent:Entity = $Entity

@export var triggerName:String = ""
@export var triggerTargetName:String = ""

export(Enums.EnemyType) var type = Enums.EnemyType.Punk
@export var delaySpawn:bool = false
@export var spawnAlert:bool = false
@export var sniper:bool = false

export(Enums.EnemyType) var veryEasyOverride = Enums.EnemyType.Punk
export(Enums.EnemyType) var typeEasyOverride = Enums.EnemyType.Punk

var _used:bool = false
# var _prefabName:String = "mob_punk"
var _childId:int = 0

func _ready() -> void:
	if Main.is_in_game():
		visible = false
	add_to_group(Groups.GAME_GROUP_NAME)
	var _result = _ent.connect("entity_append_state", self, "append_state")
	_result = _ent.connect("entity_restore_state", self, "restore_state")
	_result = _ent.connect("entity_trigger", self, "on_trigger")
	_ent.selfName = triggerName
	_ent.triggerTargetName = triggerTargetName

func append_state(_dict:Dictionary) -> void:
	_dict.xform = ZqfUtils.transform_to_dict(self.global_transform)
	_dict.used = _used
	_dict.type = type
	_dict.ds = delaySpawn
	_dict.sa = spawnAlert
	_dict.s = sniper
	_dict.c = _childId

func restore_state(_dict:Dictionary) -> void:
	ZqfUtils.safe_dict_apply_transform(_dict, "xform", self)
	_used = ZqfUtils.safe_dict_b(_dict, "used", _used)
	type = ZqfUtils.safe_dict_i(_dict, "type", type)
	delaySpawn = ZqfUtils.safe_dict_b(_dict, "ds", delaySpawn)
	spawnAlert = ZqfUtils.safe_dict_b(_dict, "sa", spawnAlert)
	sniper = ZqfUtils.safe_dict_b(_dict, "s", sniper)
	_childId = ZqfUtils.safe_dict_i(_dict, "c", _childId)

func get_editor_info() -> Dictionary:
	visible = true
	var info = { prefab = _ent.prefabName, fields = {}, rotatable = true }
	ZEEMain.create_field(info.fields, "sn", "Self Name", "text", _ent.selfName)
	ZEEMain.create_field(info.fields, "tcsv", "Target CSV", "text", _ent.triggerTargetName)
	ZEEMain.create_field(info.fields, "type", "Mob Type", "int", type)
	ZEEMain.create_field(info.fields, "ds", "Delay Spawn", "bool", delaySpawn)
	ZEEMain.create_field(info.fields, "sa", "Spawn Alert", "bool", spawnAlert)
	ZEEMain.create_field(info.fields, "s", "Is Static", "bool", sniper)
	return info

func restore_from_editor(dict:Dictionary) -> void:
	_ent.restore_state(dict)

func game_run_map_spawns() -> void:
	if !delaySpawn:
		on_trigger("", ZqfUtils.EMPTY_DICT)

func on_mob_died(_mob) -> void:
	# print("Spawn proxy saw child die")
	emit_signal("trigger")

func on_trigger(_msg:String, _params:Dictionary) -> void:
	if _used:
		return
	# spawn mob
	_used = true
	# print("Proxy spawning mob type " + str(type))
	var mob = Ents.create_mob_by_enum(type, global_transform, spawnAlert)
	_childId = mob.get_node("Entity").id
	# print("Spawned mob Id " + str(_childId))
	mob.set_source(self, _ent.id)
	mob.set_trigger_names("", _ent.triggerTargetName)
	mob.set_behaviour(sniper)
