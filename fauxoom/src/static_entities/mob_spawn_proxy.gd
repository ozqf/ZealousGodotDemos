extends Spatial
class_name MobSpawnProxy

signal trigger()

onready var _ent:Entity = $Entity

enum EnemyType {
	Punk,
	Gunner,
	FleshWorm,
	Gasbag
}
export(EnemyType) var type = EnemyType.Gunner
export var delaySpawn:bool = false
export var spawnAlert:bool = false

var _used:bool = false

func _ready() -> void:
	visible = false
	print("Spawn proxy ready")
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
	print("Spawn proxy saw child die")
	emit_signal("trigger")

func on_trigger() -> void:
	if _used:
		return
	# spawn mob
	_used = true
	var mob = Ents.get_prefab_def(Entities.PREFAB_MOB_PUNK).prefab.instance()
	Game.get_dynamic_parent().add_child(mob)
	mob.teleport(global_transform)
	if spawnAlert:
		mob.force_awake()
	# no id to set this way!
	mob.set_source(self, _ent.id)
