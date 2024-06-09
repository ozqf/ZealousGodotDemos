extends Node3D

func _ready():
	var mob:MobBase = Game.spawn_mob_dummy() as MobBase
	var spawnInfo:MobSpawnInfo = mob.get_spawn_info()
	spawnInfo.t = self.global_transform
	mob.spawn()
