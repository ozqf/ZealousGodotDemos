extends Node3D
class_name MobSpawner

@export var debug:bool = false
@export var mobPrefab:String = ""
@export var loopPath:bool = false
@export var stopAtEndOfPath:bool = false
@export var delay:float = 0.5
@export var totalToSpawn:int = 0
@export var liveLimit:int = 0

# count the number of nodes we had before adding mobs
# so that editor meshes etc can be ignored in the count
var _initialNodeCount:int = 0

var _spawnNodes:Array[Node3D] = []
var _spawnNodeIndex:int = 0

var _numRemaining:int = 0
var _numSpawned:int = 0

var _running:bool = false
var _tick:float = 0.0

func _ready() -> void:
	set_physics_process(false)

func start() -> void:
	if _running:
		return
	if debug:
		print("Spawner start")
	_running = true
	_numSpawned = 0
	_numRemaining = 0
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
		if debug:
			print("Spawn node adding self as origin")
		_spawnNodes.push_back(self)
	
	var numSpawnNodes:int = _spawnNodes.size()
	
	totalToSpawn = clampi(totalToSpawn, 0, 50)
	if totalToSpawn <= 0:
		totalToSpawn = numSpawnNodes
	
	if liveLimit <= 0:
		liveLimit = numSpawnNodes
	elif liveLimit > totalToSpawn:
		liveLimit = totalToSpawn
	set_physics_process(true)

func _spawn_mob(n:Node3D) -> void:
	_numSpawned += 1
	var t:Transform3D = n.global_transform
	var mob:Mob = Mob.spawn_new_mob(self.mobPrefab, t, self, false)
	mob.source = self
	mob.startNode = n
	mob.start_mob()

func _physics_process(delta: float) -> void:
	if !_running:
		set_physics_process(false)
		return
	_tick -= delta
	var count:int = self.get_child_count()
	count -= _initialNodeCount
	# completed check
	if _numSpawned >= totalToSpawn:
		if count == 0:
			_running = false
			set_physics_process(false)
		return
	if count < liveLimit && _tick <= 0.0:
		_tick = delay
		var i:int = _spawnNodeIndex % _spawnNodes.size()
		_spawnNodeIndex += 1
		var n:Node3D = _spawnNodes[i]
		_spawn_mob(n)
		print("Spawn mob " + str(_numSpawned) + " of " + str(totalToSpawn))

func finished() -> bool:
	return !_running
