extends Spatial
class_name Entities

const MOB_PUNK:String = "mob_punk"
const MOB_GUNNER:String = "mob_gunner"
const PLAYER:String = "player"
const GIB:String = "gib"

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

func get_prefab(_name:String) -> Object:
	if !_prefabs.has(_name):
		print("No EntityType '" + _name + "' found!")
		return null
	return _prefabs[_name].prefab


