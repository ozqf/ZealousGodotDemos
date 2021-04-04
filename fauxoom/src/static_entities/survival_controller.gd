extends Spatial

onready var _child_spawner = $horde_spawns/horde_spawn

export var selfName:String = ""
export var triggerTargetName:String = ""

var _state:Dictionary
var _active:bool = false

var _spawnTransforms = []
var _northernTransforms = []

func _ready() -> void:
	visible = false
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.ENTS_GROUP_NAME)
	_state = write_state()
	var spawnPoints:Spatial = get_node("spawn_points")
	var numPoints:int = spawnPoints.get_child_count()
	for _i in range(0, numPoints):
		_spawnTransforms.push_back(spawnPoints.get_child(_i).global_transform)
	
	_northernTransforms.push_back($spawn_points/n.global_transform)
	_northernTransforms.push_back($spawn_points/nw.global_transform)
	_northernTransforms.push_back($spawn_points/ne.global_transform)
	
	_child_spawner.noSelfSave = true
	_child_spawner.set_spawn_points(_northernTransforms)

func _process(_delta:float) -> void:
	if !_active:
		return

func game_on_reset() -> void:
	restore_state(_state)

func on_trigger_entities(target:String) -> void:
	if target == "":
		return
	if target == selfName && _active == false:
		_active = true
		print("Survival start")
		_child_spawner.tickMax = 0.1
		_child_spawner.totalMobs = 10
		_child_spawner.maxLiveMobs = 10
		_child_spawner.start()

func write_state() -> Dictionary:
	return {
		active = _active,
		spawner_1 = _child_spawner.write_state()
	}

func restore_state(data:Dictionary) -> void:
	_active = data.active
	_child_spawner.restore_state(data.spawner_1)
