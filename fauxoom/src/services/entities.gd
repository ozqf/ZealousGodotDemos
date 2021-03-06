extends Spatial
class_name Entities

const Enums = preload("res://src/enums.gd")

const EMPTY_ID:int = 0
const PLAYER_RESERVED_ID:int = 1

const PREFAB_MOB_PUNK:String = "mob_punk"
const PREFAB_MOB_WORM:String = "mob_worm"
const PREFAB_MOB_CYCLOPS:String = "mob_cyclops"
const PREFAB_MOB_GUNNER:String = "mob_gunner"
const PREFAB_MOB_SERPENT:String = "mob_serpent"
const PREFAB_MOB_SPIDER:String = "mob_spider"
const PREFAB_MOB_TITAN:String = "mob_titan"
const PREFAB_PLAYER:String = "player"
const PREFAB_GIB:String = "gib"

var _prefabs = {
	mob_punk = {
		prefab = preload("res://prefabs/dynamic_entities/mob_punk.tscn"),
		entNodePath = "Entity"
	},
	mob_worm = {
		prefab = preload("res://prefabs/dynamic_entities/mob_flesh_worm.tscn"),
		entNodePath = "Entity"
	},
	mob_gunner = {
		prefab = preload("res://prefabs/dynamic_entities/mob_gunner.tscn"),
		entNodePath = "Entity"
	},
	mob_cyclops = {
		prefab = preload("res://prefabs/dynamic_entities/mob_cyclops.tscn"),
		entNodePath = "Entity"
	},
	mob_serpent = {
		prefab = preload("res://prefabs/dynamic_entities/mob_serpent.tscn"),
		entNodePath = "Entity"
	},
	mob_spider = {
		prefab = preload("res://prefabs/dynamic_entities/mob_spider.tscn"),
		entNodePath = "Entity"
	},
	mob_titan = {
		prefab = preload("res://prefabs/dynamic_entities/mob_titan.tscn"),
		entNodePath = "Entity"
	},

	player = {
		prefab = preload("res://prefabs/player.tscn"),
		entNodePath = "Entity"
	},
	hp_l = {
		prefab = preload("res://prefabs/items/item_health_large.tscn"),
		entNodePath = "Entity"
	},

	chainsaw = {
		prefab = preload("res://prefabs/items/item_chainsaw.tscn"),
		entNodePath = "Entity"
	},
	pistol = {
		prefab = preload("res://prefabs/items/item_pistol.tscn"),
		entNodePath = "Entity"
	},
	ssg = {
		prefab = preload("res://prefabs/items/item_super_shotgun.tscn"),
		entNodePath = "Entity"
	},
	pg = {
		prefab = preload("res://prefabs/items/item_plasma_gun.tscn"),
		entNodePath = "Entity"
	},
	rocket_launcher = {
		prefab = preload("res://prefabs/items/item_rocket_launcher.tscn"),
		entNodePath = "Entity"
	},

	shell_s = {
		prefab = preload("res://prefabs/items/item_shells_small.tscn"),
		entNodePath = "Entity"
	},
	bullet_l = {
		prefab = preload("res://prefabs/items/item_bullets_large.tscn"),
		entNodePath = "Entity"
	},
	shell_l = {
		prefab = preload("res://prefabs/items/item_shells_large.tscn"),
		entNodePath = "Entity"
	},
	rocket_l = {
		prefab = preload("res://prefabs/items/item_rockets_large.tscn"),
		entNodePath = "Entity"
	},
	gib = {
		prefab = preload("res://prefabs/gib.tscn"),
		entNodePath = "Entity"
	}
}

var _nextDynamicId:int = PLAYER_RESERVED_ID + 1
var _nextStaticId:int = -1

func _ready() -> void:
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	add_to_group(Groups.GAME_GROUP_NAME)

func game_on_map_change() -> void:
	_nextDynamicId = PLAYER_RESERVED_ID + 1
	_nextStaticId = -1

func get_prefab_def(_name:String) -> Dictionary:
	if !_prefabs.has(_name):
		print("No EntityType '" + _name + "' found!")
		return {}
	return _prefabs[_name]

func _select_prefab(enemyType:int) -> String:
	if enemyType == Enums.EnemyType.FleshWorm:
		return PREFAB_MOB_WORM
	elif enemyType == Enums.EnemyType.Spider:
		return PREFAB_MOB_SPIDER
	elif enemyType == Enums.EnemyType.Serpent:
		return PREFAB_MOB_SERPENT
	elif enemyType == Enums.EnemyType.Cyclops:
		return PREFAB_MOB_CYCLOPS
	elif enemyType == Enums.EnemyType.Titan:
		return PREFAB_MOB_TITAN
	elif enemyType == Enums.EnemyType.Punk:
		return PREFAB_MOB_PUNK
	else:
		print("Ents - unknown enemy type " + str(enemyType))
		return PREFAB_MOB_PUNK

func create_mob(enemyType:int, _transform:Transform, alert:bool):
	var prefabLabel:String = _select_prefab(enemyType)
	var mob = get_prefab_def(prefabLabel).prefab.instance()
	Game.get_dynamic_parent().add_child(mob)
	mob.teleport(_transform)
	if alert:
		mob.force_awake()
	return mob

func assign_dynamic_id() -> int:
	var id:int = _nextDynamicId
	_nextDynamicId += 1
	return id

func assign_static_id() -> int:
	var id:int = _nextStaticId
	_nextStaticId -= 1
	return id

func _delete_all_dynamic_entities() -> void:
	var dynEnts = get_tree().get_nodes_in_group(Groups.DYNAMIC_ENTS_GROUP_NAME)
	for ent in dynEnts:
		ent.get_parent().queue_free()

func find_static_entity_by_id(id:int) -> Node:
	if id >= 0:
		return null
	var staticEnts = get_tree().get_nodes_in_group(Groups.STATIC_ENTS_GROUP_NAME)
	for ent in staticEnts:
		if ent.id == id:
			return ent
	return null

#################################################
# save/load
func write_save_dict() -> Dictionary:
	var staticEnts = get_tree().get_nodes_in_group(Groups.STATIC_ENTS_GROUP_NAME)
	var dynEnts = get_tree().get_nodes_in_group(Groups.DYNAMIC_ENTS_GROUP_NAME)
	var data = {
		nextDynamicId = _nextDynamicId,
		nextStaticId = _nextStaticId,
		numStatic = staticEnts.size(),
		numDynamic = dynEnts.size(),
		dynamicData = [],
		staticData = []
	}
	for _i in range(0, staticEnts.size()):
		var ent = staticEnts[_i]
		data.staticData.push_back(ent.write_state())
	for _i in range(0, dynEnts.size()):
		var ent = dynEnts[_i]
		data.dynamicData.push_back(ent.write_state())
	return data

func restore_dynamic_entity(dict:Dictionary) -> void:
	var def = get_prefab_def(dict.prefab)
	assert(def != null)
	var prefab = def.prefab.instance()
	add_child(prefab)
	prefab.get_node(def.entNodePath).restore_state(dict)

func load_save_dict(data:Dictionary) -> void:
	# print("Read save")
	# print("Static ents: " + str(data.numStatic))
	# print("Dynamic ents: " + str(data.numDynamic))

	_nextDynamicId = data.nextDynamicId
	_nextStaticId = data.nextStaticId

	# static entities - find and load
	var staticEnts = get_tree().get_nodes_in_group(Groups.STATIC_ENTS_GROUP_NAME)
	for entData in data.staticData:
		var id:int = entData.id
		# find entity
		var ent = null
		for staticEnt in staticEnts:
			if staticEnt.id == id: 
				ent = staticEnt
				break
		if ent == null:
			print("Could not find static entity with Id " + str(id))
			continue
		ent.restore_state(entData)

	# dynamic entities - delete all and recreate
	_delete_all_dynamic_entities()
	for entData in data.dynamicData:
		restore_dynamic_entity(entData)
		# var def = get_prefab_def(entData.prefab)
		# assert(def != null)
		# var prefab = def.prefab.instance()
		# add_child(prefab)
		# prefab.get_node(def.entNodePath).restore_state(entData)

func console_on_exec(_txt:String, _tokens) -> void:
	if _txt == "list_ents":
		var staticEnts = get_tree().get_nodes_in_group(Groups.STATIC_ENTS_GROUP_NAME)
		var dynEnts = get_tree().get_nodes_in_group(Groups.DYNAMIC_ENTS_GROUP_NAME)
		print("Ents: "
			+ str(staticEnts.size())
			+ " static ents, "
			+ str(dynEnts.size())
			+ " dynamic ents, ")
		print("Static:")
		for _i in range(0, staticEnts.size()):
			print(staticEnts[_i].get_parent().name)
		print("Dynamic:")
		for _i in range(0, dynEnts.size()):
			print(dynEnts[_i].get_parent().name)
