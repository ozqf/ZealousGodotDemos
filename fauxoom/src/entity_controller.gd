extends Spatial
class_name Entities

const MOB_PUNK:String = "mob_punk"
const MOB_GUNNER:String = "mob_gunner"
const PLAYER:String = "player"
const GIB:String = "gib"

var _prefabs = {
	punk = {
		name = MOB_PUNK,
		prefab = preload("res://prefabs/dynamic_entities/mob_punk.tscn")
	},
	gunner = {
		name = MOB_GUNNER,
		prefab = preload("res://prefabs/dynamic_entities/mob_gunner.tscn")
	},
	player = {
		name = PLAYER,
		prefab = preload("res://prefabs/player.tscn")
	},
	gib = {
		name = GIB,
		prefab = preload("res://prefabs/gib.tscn")
	}
}

func get_prefab(_name:String) -> Object:
	return _prefabs[_name].prefab
