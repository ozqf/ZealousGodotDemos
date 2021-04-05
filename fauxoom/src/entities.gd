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
		prefab = preload("res://prefabs/dynamic_entities/mob_punk.tscn")
	},
	mob_gunner = {
		prefab = preload("res://prefabs/dynamic_entities/mob_gunner.tscn")
	},
	player = {
		prefab = preload("res://prefabs/player.tscn")
	},
	gib = {
		prefab = preload("res://prefabs/gib.tscn")
	}
}

var _nextDynamicId:int = PLAYER_RESERVED_ID + 1
var _nextStaticId:int = -1

func _ready() -> void:
	add_to_group(Groups.CONSOLE_GROUP_NAME)

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

func get_prefab(_name:String) -> Object:
	if !_prefabs.has(_name):
		print("No EntityType '" + _name + "' found!")
		return null
	return _prefabs[_name].prefab

func assign_dynamic_id() -> int:
	var id:int = _nextDynamicId
	_nextDynamicId += 1
	return id

func assign_static_id() -> int:
	var id:int = _nextStaticId
	_nextStaticId -= 1
	return id

