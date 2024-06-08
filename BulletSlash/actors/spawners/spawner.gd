extends Node3D

func _ready():
	var mob:Node3D = Game.spawn_mob_fodder()
	mob.global_position = self.global_position
