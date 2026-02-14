extends Node3D
class_name MobSpawner

@export var mobPrefab:String = ""
@export var loopPath:bool = false

# count the number of nodes we had before adding mobs
# so that editor meshes etc can be ignored in the count
var _initialNodeCount:int = 0

var _spawnNodes:Array[Node3D] = []
var _spawnNodeIndex:int = 0

func start() -> void:
	# clear stuff
	self._initialNodeCount = self.get_child_count()
	if _spawnNodes.size() > 0:
		_spawnNodes.clear()
	
	# gather spawn points to cycle through
	for child in self.get_children():
		var n:Node3D = child as Node3D
		_spawnNodes.push_back(n)
	
	# if no child points use self
	if _spawnNodes.size() == 0:
		_spawnNodes.push_back(self)

	for i in range(0, _spawnNodes.size()):
		var n:Node3D = _spawnNodes[i]
		var t:Transform3D = n.global_transform
		var mob:Mob = Mob.spawn_new_mob(self.mobPrefab, t, self, false)
		mob.source = self
		mob.startNode = n
		mob.start_mob()

	#var t:Transform3D = self.global_transform
	#var mob:Mob = Mob.spawn_new_mob(self.mobPrefab, t, self, true)

func finished() -> bool:
	var count:int = self.get_child_count()
	return (count - _initialNodeCount) == 0
