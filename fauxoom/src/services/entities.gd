extends Spatial
class_name Entities

const Enums = preload("res://src/enums.gd")

const EMPTY_ID:int = 0

const PREFAB_MOB_PUNK:String = "mob_punk"
const PREFAB_MOB_WORM:String = "mob_worm"
const PREFAB_MOB_BRAIN:String = "mob_brain"
const PREFAB_MOB_CYCLOPS:String = "mob_cyclops"
const PREFAB_MOB_GUNNER:String = "mob_gunner"
const PREFAB_MOB_SERPENT:String = "mob_serpent"
const PREFAB_MOB_SPIDER:String = "mob_spider"
const PREFAB_MOB_GOLEM:String = "mob_golem"
const PREFAB_MOB_PSYCHIC:String = "mob_psychic"
const PREFAB_MOB_TITAN:String = "mob_titan"

# const PREFAB_PLAYER:String = "player"
const PREFAB_GIB:String = "gib"

var _prefabs = {
	################################################
	# mobs
	################################################
	mob_punk = {
		# name field should always = the dictionary key, and is set
		# during _ready()
		name = "mob_punk",
		prefab = preload("res://prefabs/dynamic_entities/mob_punk.tscn"),
		entNodePath = "Entity",
		label = "Punk",
		noEditor = true
	},
	mob_worm = {
		prefab = preload("res://prefabs/dynamic_entities/mob_flesh_worm.tscn"),
		entNodePath = "Entity",
		label = "Worm",
		noEditor = true
	},
	mob_gunner = {
		prefab = preload("res://prefabs/dynamic_entities/mob_gunner.tscn"),
		entNodePath = "Entity",
		label = "Gunner",
		noEditor = true
	},
	mob_cyclops = {
		prefab = preload("res://prefabs/dynamic_entities/mob_cyclops.tscn"),
		entNodePath = "Entity",
		label = "Cyclops",
		noEditor = true
	},
	mob_serpent = {
		prefab = preload("res://prefabs/dynamic_entities/mob_serpent.tscn"),
		entNodePath = "Entity",
		label = "Serpent",
		noEditor = true
	},
	mob_spider = {
		prefab = preload("res://prefabs/dynamic_entities/mob_spider.tscn"),
		entNodePath = "Entity",
		noEditor = true
	},
	mob_golem = {
		prefab = preload("res://prefabs/dynamic_entities/mob_golem.tscn"),
		entNodePath = "Entity",
		noEditor = true
	},
	mob_titan = {
		prefab = preload("res://prefabs/dynamic_entities/mob_titan.tscn"),
		entNodePath = "Entity",
		noEditor = true
	},

	################################################
	# player
	################################################
	player = {
		prefab = preload("res://prefabs/player.tscn"),
		entNodePath = "Entity",
		noEditor = true
	},
	################################################
	# health
	################################################
	hp_s = {
		prefab = preload("res://prefabs/items/item_health_small.tscn"),
		entNodePath = "Entity",
		category = "items"
	},
	hp_l = {
		prefab = preload("res://prefabs/items/item_health_large.tscn"),
		entNodePath = "Entity",
		category = "items"
	},
	hazard_suit = {
		prefab = preload("res://prefabs/items/item_hazard_suit.tscn"),
		entNodePath = "Entity"
	},
	frage = {
		prefab = preload("res://prefabs/items/item_full_rage.tscn"),
		entNodePath = "Entity",
		category = "items"
	},

	################################################
	# weapons
	################################################
	chainsaw = {
		prefab = preload("res://prefabs/items/item_chainsaw.tscn"),
		category = "items"
	},
	pistol = {
		prefab = preload("res://prefabs/items/item_pistol.tscn"),
		category = "items"
	},
	ssg = {
		prefab = preload("res://prefabs/items/item_super_shotgun.tscn"),
		category = "items"
	},
	pg = {
		prefab = preload("res://prefabs/items/item_plasma_gun.tscn"),
		category = "items"
	},
	rocket_launcher = {
		prefab = preload("res://prefabs/items/item_rocket_launcher.tscn"),
		category = "items"
	},
	flame_thrower = {
		prefab = preload("res://prefabs/items/item_flame_thrower.tscn"),
		category = "items"
	},

	################################################
	# ammo
	################################################
	shell_s = {
		prefab = preload("res://prefabs/items/item_shells_small.tscn"),
		category = "items"
	},
	shell_l = {
		prefab = preload("res://prefabs/items/item_shells_large.tscn"),
		category = "items"
	},
	bullet_s = {
		prefab = preload("res://prefabs/items/item_bullets_small.tscn"),
		category = "items"
	},
	bullet_l = {
		prefab = preload("res://prefabs/items/item_bullets_large.tscn"),
		category = "items"
	},
	rocket_s = {
		prefab = preload("res://prefabs/items/item_rockets_small.tscn"),
		category = "items"
	},
	rocket_l = {
		prefab = preload("res://prefabs/items/item_rockets_large.tscn"),
		category = "items"
	},
	cell_s = {
		prefab = preload("res://prefabs/items/item_cells_small.tscn"),
		category = "items"
	},
	cell_l = {
		prefab = preload("res://prefabs/items/item_cells_large.tscn"),
		entNodePath = "Entity",
		category = "items"
	},
	fuel_s = {
		prefab = preload("res://prefabs/items/item_fuel_small.tscn"),
		category = "items"
	},
	fuel_l = {
		prefab = preload("res://prefabs/items/item_fuel_large.tscn"),
		category = "items"
	},
	fullpack = {
		prefab = preload("res://prefabs/items/item_full_pack.tscn"),
		category = "items"
	},
	gunrack = {
		prefab = preload("res://prefabs/items/item_gun_rack.tscn"),
		category = "items"
	},

	################################################
	# info
	################################################
	player_start = {
		prefab = preload("res://prefabs/static_entities/player_start.tscn"),
		category = "info",
		label = "Player Start"
	},
	trigger_volume = {
		prefab = preload("res://prefabs/static_entities/trigger_volume.tscn"),
		category = "info",
		label = "Trigger Volume"
	},
	player_barrier_volume = {
		prefab = preload("res://prefabs/static_entities/player_barrier_volume.tscn"),
		label = "Barrier Volume"
	},
	info_destination = {
		prefab = preload("res://prefabs/static_entities/teleport_destination.tscn"),
		label = "Info Destination"
	},
	info_point = {
		prefab = preload("res://prefabs/static_entities/info_point_entity.tscn"),
		label = "Info Point"
	},
	door_tech_01 = {
		prefab = preload("res://prefabs/doors/tech_door_01.tscn"),
		label = "Door - Tech 01"
	},
	king_tower = {
		prefab = preload("res://prefabs/KingTower.tscn"),
		label = "King of the Hill Tower"
	},

	################################################
	# barrels
	################################################
	barrel_he = {
		prefab = preload("res://prefabs/carriable/barrel_explosive.tscn"),
		entNodePath = "Entity",
		category = "items"
	},

	################################################
	# debris
	################################################
	gib = {
		prefab = preload("res://prefabs/gib.tscn"),
		entNodePath = "Entity",
		noEditor = true
	}
}

var _nextDynamicId:int = Interactions.PLAYER_RESERVED_ID + 1
var _nextStaticId:int = -1

func _ready() -> void:
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	add_to_group(Groups.GAME_GROUP_NAME)

	# patch missing fields in prefab defs
	var keys = _prefabs.keys()
	for i in range(0, keys.size()):
		var key = keys[i]
		var prefab:Dictionary = _prefabs[key]
		prefab.name = key
		if !prefab.has("entNodePath"):
			prefab.entNodePath = "Entity"
		if !prefab.has("label"):
			prefab.label = key
		if !prefab.has("noEditor"):
			prefab.noEditor = false

func get_prefabs_copy() -> Dictionary:
	return _prefabs.duplicate(true)

func game_on_map_change() -> void:
	_nextDynamicId = Interactions.PLAYER_RESERVED_ID + 1
	_nextStaticId = -1

func get_prefab_def(_name:String) -> Dictionary:
	if _name == null || _name == "":
		push_error("Empty prefab name")
		return {}
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
	elif enemyType == Enums.EnemyType.Golem:
		return PREFAB_MOB_GOLEM
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
	# Game.get_dynamic_parent().add_child(mob)
	self.add_child(mob)
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
		ent.get_parent().free()

func find_static_entity_by_id(id:int) -> Entity:
	if id >= 0:
		return null
	var staticEnts = get_tree().get_nodes_in_group(Groups.STATIC_ENTS_GROUP_NAME)
	for ent in staticEnts:
		if ent.id == id:
			return ent as Entity
	return null

func find_static_entity_by_name(entName:String) -> Entity:
	if entName == null || entName == "":
		return null
	var staticEnts = get_tree().get_nodes_in_group(Groups.STATIC_ENTS_GROUP_NAME)
	for ent in staticEnts:
		if ent.selfName == entName:
			return ent as Entity
	return null

func find_dynamic_entity_by_name(entName:String) -> Entity:
	if entName == null || entName == "":
		return null
	var ents = get_tree().get_nodes_in_group(Groups.DYNAMIC_ENTS_GROUP_NAME)
	for ent in ents:
		if ent.selfName == entName:
			return ent as Entity
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
	# print("Restoring prefab " + dict.prefab)
	var prefab = def.prefab.instance()
	add_child(prefab)
	prefab.get_node(def.entNodePath).restore_state(dict)
	if Main.get_app_state() == Enums.AppState.Editor:
		get_tree().call_group(
			Groups.ENTS_GROUP_NAME, Groups.ENTS_FN_RESTORED_ENTITY, prefab, def)

func load_save_dict(data:Dictionary) -> void:
	# print("Read save")
	# print("Static ents: " + str(data.numStatic))
	# print("Dynamic ents: " + str(data.numDynamic))

	_nextDynamicId = data.nextDynamicId
	_nextStaticId = data.nextStaticId

	# static entities - find and load
	print("Restoring static entities")
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
	print("Delete dynamic entities")
	_delete_all_dynamic_entities()
	print("Restore dynamic entities")
	for entData in data.dynamicData:
		restore_dynamic_entity(entData)

func load_entities_file(_entFilePath:String) -> void:
	var data = ZqfUtils.load_dict_json_file(_entFilePath)
	pass

func console_on_exec(_txt:String, _tokens) -> void:
	if _tokens[0] == "list_ents":
		var txt:String = ""
		var staticEnts = get_tree().get_nodes_in_group(Groups.STATIC_ENTS_GROUP_NAME)
		var dynEnts = get_tree().get_nodes_in_group(Groups.DYNAMIC_ENTS_GROUP_NAME)
		txt += "Ents: " + str(staticEnts.size()) + " static ents, " + str(dynEnts.size()) + " dynamic ents\n"
		txt += "Static:\n"
		var noNamesCount:int = 0
		for _i in range(0, staticEnts.size()):
			var ent = staticEnts[_i]
			txt += "> " + ent.get_label() + " targets: " + ent.triggerTargetName + "\n"
		txt += "Dynamic:\n"
		for _i in range(0, dynEnts.size()):
			var ent = dynEnts[_i]
			txt += "> " + ent.get_label() + " targets: " + ent.triggerTargetName + "\n"
		if _tokens.size() == 1:
			print(txt)
			return
		var path = "user://" + _tokens[1] + ".txt"
		var file = File.new()
		var err = file.open(path, File.WRITE)
		if err != 0:
			print("Err opening " + path + " to save ent list")
			return
		print("List ents - writing " + str(txt.length()) + " to " + path)
		file.store_string(txt)
		file.close()
		
