extends Node3D

@export var mobType:String = "dummy"

func _ready():
	
	var mob:MobBase = null
	match mobType:
		"fodder":
			mob = Game.spawn_mob_fodder() as MobBase
		_:
			mob = Game.spawn_mob_dummy() as MobBase
	var spawnInfo:MobSpawnInfo = mob.get_spawn_info()
	spawnInfo.t = self.global_transform
	mob.spawn()
