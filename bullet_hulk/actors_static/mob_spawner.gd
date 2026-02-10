extends Node3D
class_name MobSpawner

@export var mobPrefab:String = ""

# count the number of nodes we had before adding mobs
# so that editor meshes etc can be ignored in the count
var initialNodeCount:int = 0

func start() -> void:
	self.initialNodeCount = self.get_child_count()
	var t:Transform3D = self.global_transform
	match self.mobPrefab:
		Mob.MOB_PREFAB_BRUTE:
			Game.spawn_brute(t, self)
		Mob.MOB_PREFAB_FODDER, _:
			Game.spawn_fodder(t, self)

func finished() -> bool:
	var count:int = self.get_child_count()
	return (count - initialNodeCount) == 0
