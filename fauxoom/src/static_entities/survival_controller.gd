extends Spatial

onready var _child_spawner = $horde_spawns/horde_spawn
onready var _ent:Entity = $Entity

export var selfName:String = ""
export var triggerTargetName:String = ""

var _active:bool = false

var _spawnTransforms = []
var _northernTransforms = []

func _ready() -> void:
	visible = false
	var _r
	_r = _ent.connect("entity_append_state", self, "append_state")
	_r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_trigger", self, "on_trigger")
	_ent.selfName = selfName

	var spawnPoints:Spatial = get_node("spawn_points")
	var numPoints:int = spawnPoints.get_child_count()
	for _i in range(0, numPoints):
		_spawnTransforms.push_back(spawnPoints.get_child(_i).global_transform)
	
	_northernTransforms.push_back($spawn_points/n.global_transform)
	_northernTransforms.push_back($spawn_points/nw.global_transform)
	_northernTransforms.push_back($spawn_points/ne.global_transform)
	
	_child_spawner.set_spawn_points(_northernTransforms)

func _process(_delta:float) -> void:
	if !_active:
		return

func on_trigger() -> void:
	_active = true
	print("Survival start")
	# _child_spawner.tickMax = 0.25
	# _child_spawner.totalMobs = 9999
	# _child_spawner.maxLiveMobs = 10
	_child_spawner.on_trigger()

func append_state(_dict:Dictionary) -> void:
	_dict.active = _active

func restore_state(data:Dictionary) -> void:
	_active = data.active
