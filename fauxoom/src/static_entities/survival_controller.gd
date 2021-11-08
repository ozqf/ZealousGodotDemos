extends Spatial

onready var _ent:Entity = $Entity
onready var _punk_spawner = $horde_spawns/punk_spawn
onready var _worm_spawner = $horde_spawns/worm_spawn

export var selfName:String = ""
export var triggerTargetName:String = ""
export var spawnPointsSiblingName:String = ""

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

	var spawnPoints:Spatial = get_parent().get_node("arena_spawn_points")
	var numPoints:int = spawnPoints.get_child_count()
	for _i in range(0, numPoints):
		_spawnTransforms.push_back(spawnPoints.get_child(_i).global_transform)

	var cardinalTransforms = []
	cardinalTransforms.push_back(spawnPoints.get_node("n").global_transform)
	cardinalTransforms.push_back(spawnPoints.get_node("s").global_transform)
	cardinalTransforms.push_back(spawnPoints.get_node("w").global_transform)
	cardinalTransforms.push_back(spawnPoints.get_node("e").global_transform)
	
	_punk_spawner.set_spawn_points(cardinalTransforms)
	_worm_spawner.set_spawn_points(cardinalTransforms)

func _process(_delta:float) -> void:
	if !_active:
		return

func on_trigger() -> void:
	_active = true
	print("Survival start")
	# _punk_spawner.tickMax = 0.25
	# _punk_spawner.totalMobs = 9999
	# _punk_spawner.maxLiveMobs = 10
	_punk_spawner.on_trigger()
	_worm_spawner.on_trigger()

func append_state(_dict:Dictionary) -> void:
	_dict.active = _active

func restore_state(data:Dictionary) -> void:
	_active = data.active
