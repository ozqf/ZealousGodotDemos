extends Spatial

onready var _ent:Entity = $Entity
#onready var _punk_spawner = $horde_spawns/punk_spawn
#onready var _worm_spawner = $horde_spawns/worm_spawn

export var selfName:String = ""
export var triggerTargetName:String = ""
export var spawnPointsSiblingName:String = ""

var _active:bool = false

var _spawnTransforms = []
var _northernTransforms = []
var _spawners = []

func _ready() -> void:
	visible = false
	var _r
	_r = _ent.connect("entity_append_state", self, "append_state")
	_r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_trigger", self, "on_trigger")
	_ent.selfName = selfName

	var allTransforms = []
	var spawnPoints:Spatial = get_parent().get_node(spawnPointsSiblingName)
	var numPoints:int = spawnPoints.get_child_count()
	for _i in range(0, numPoints):
		var child = spawnPoints.get_child(_i)
		_spawnTransforms.push_back(child.global_transform)
		allTransforms.push_back(child.global_transform)
	
	var useSubset:bool = false
	var cardinalTransforms = []
	#cardinalTransforms.push_back(spawnPoints.get_node("n").global_transform)
	#cardinalTransforms.push_back(spawnPoints.get_node("s").global_transform)
	#cardinalTransforms.push_back(spawnPoints.get_node("w").global_transform)
	#cardinalTransforms.push_back(spawnPoints.get_node("e").global_transform)
	
	var spawnsParent = $horde_spawns
	var numSpawners:int = spawnsParent.get_child_count()
	for _i in range(0, numSpawners):
		_spawners.push_back(spawnsParent.get_child(_i))
	
	if useSubset:
		set_all_spawner_destinations(cardinalTransforms)
#		_punk_spawner.set_spawn_points(cardinalTransforms)
#		_worm_spawner.set_spawn_points(cardinalTransforms)
	else:
		set_all_spawner_destinations(allTransforms)
#		_punk_spawner.set_spawn_points(cardinalTransforms)
#		_worm_spawner.set_spawn_points(cardinalTransforms)

func _process(_delta:float) -> void:
	if !_active:
		return

func set_all_spawner_destinations(transformsArray) -> void:
	for i in range(0, _spawners.size()):
		if !_spawners[i].has_method("set_spawn_points"):
			print("node " + str(_spawners[i].name) + " has no set spawn points function")
		_spawners[i].set_spawn_points(transformsArray)

func start_wave_spawners() -> void:
	for i in range(0, _spawners.size()):
		_spawners[i].on_trigger()

func on_trigger() -> void:
	_active = true
	print("Survival start")
	# _punk_spawner.tickMax = 0.25
	# _punk_spawner.totalMobs = 9999
	# _punk_spawner.maxLiveMobs = 10
	start_wave_spawners()
#	_punk_spawner.on_trigger()
#	_worm_spawner.on_trigger()

func append_state(_dict:Dictionary) -> void:
	_dict.active = _active

func restore_state(data:Dictionary) -> void:
	_active = data.active
