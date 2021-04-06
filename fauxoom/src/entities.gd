extends Spatial
class_name Entities

const EMPTY_ID:int = 0
const PLAYER_RESERVED_ID:int = 1

const PREFAB_MOB_PUNK:String = "mob_punk"
const PREFAB_MOB_GUNNER:String = "mob_gunner"
const PREFAB_PLAYER:String = "player"
const PREFAB_GIB:String = "gib"

var _prefabs = {
	mob_punk = {
		prefab = preload("res://prefabs/dynamic_entities/mob_punk.tscn"),
		entNodePath = "Entity"
	},
	mob_gunner = {
		prefab = preload("res://prefabs/dynamic_entities/mob_gunner.tscn"),
		entNodePath = "Entity"
	},
	player = {
		prefab = preload("res://prefabs/player.tscn"),
		entNodePath = "Entity"
	},
	ssg = {
		prefab = preload("res://prefabs/items/item_super_shotgun.tscn"),
		entNodePath = "Entity"
	},
	shell_s = {
		prefab = preload("res://prefabs/items/item_shells_small.tscn"),
		entNodePath = "Entity"
	},
	shell_l = {
		prefab = preload("res://prefabs/items/item_shells_large.tscn"),
		entNodePath = "Entity"
	},
	gib = {
		prefab = preload("res://prefabs/gib.tscn"),
		entNodePath = "Entity"
	}
}

var _nextDynamicId:int = PLAYER_RESERVED_ID + 1
var _nextStaticId:int = -1

const QUICK_SAVE_FILE_NAME:String = "user://fauxoom_quick.json"

func _ready() -> void:
	add_to_group(Groups.CONSOLE_GROUP_NAME)

func get_prefab_def(_name:String) -> Dictionary:
	if !_prefabs.has(_name):
		print("No EntityType '" + _name + "' found!")
		return {}
	return _prefabs[_name]

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

#################################################
# save/load
func _write_save_dict() -> Dictionary:
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
	print("Static:")
	for _i in range(0, staticEnts.size()):
		var ent = staticEnts[_i]
		data.staticData.push_back(ent.write_state())
	print("Dynamic:")
	for _i in range(0, dynEnts.size()):
		var ent = dynEnts[_i]
		data.dynamicData.push_back(ent.write_state())
	return data

func _write_save_file(filePath:String, data:Dictionary) -> void:
	# write file
	var file = File.new()
	file.open(filePath, File.WRITE)
	file.store_string(to_json(data))
	file.close()

func _stage_file_for_load(_name:String) -> Dictionary:
	var file = File.new()
	if !file.file_exists(_name):
		print("No file " + str(_name) + " to load")
		return {}
	file.open(_name, File.READ)
	var data = parse_json(file.get_as_text())
	file.close()
	return data

func _load_save_dict(data:Dictionary) -> void:
	print("Read save")
	print("Static ents: " + str(data.numStatic))
	print("Dynamic ents: " + str(data.numDynamic))

	_nextDynamicId = data.nextDynamicId
	_nextStaticId = data.nextStaticId

	# static entities - find and load
	var staticEnts = get_tree().get_nodes_in_group(Groups.STATIC_ENTS_GROUP_NAME)
	for entData in data.staticData:
		var id:int = entData.id
		print("Load static ent " + str(id))
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
		print("Spawn dynamic ent type " + entData.prefab)
		var def = get_prefab_def(entData.prefab)
		assert(def != null)
		var prefab = def.prefab.instance()
		add_child(prefab)
		print("Restore state")
		prefab.get_node(def.entNodePath).restore_state(entData)

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
	elif _txt == "save":
		var data:Dictionary = _write_save_dict()
		_write_save_file(QUICK_SAVE_FILE_NAME, data)
	elif _txt == "load":
		var data:Dictionary = _stage_file_for_load(QUICK_SAVE_FILE_NAME)
		if !data:
			return
		_load_save_dict(data)


