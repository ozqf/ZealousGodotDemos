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
	if spawnPointsSiblingName == "":
		_spawnTransforms.push_back(self.global_transform)
		allTransforms.push_back(self.global_transform)
	else:
		var spawnPoints:Spatial = get_parent().get_node(spawnPointsSiblingName)
		if spawnPoints != null:
			var numPoints:int = spawnPoints.get_child_count()
			for _i in range(0, numPoints):
				var child = spawnPoints.get_child(_i)
				_spawnTransforms.push_back(child.global_transform)
				allTransforms.push_back(child.global_transform)
		else:
			_spawnTransforms.push_back(self.global_transform)
			allTransforms.push_back(self.global_transform)
	
	var useSubset:bool = false
	var cardinalTransforms = []
	
	# var spawnsParent = $horde_spawns
	var spawnsParent = find_node("horde_spawns")
	if spawnsParent == null:
		print("Arena Controller has no spawners!")
		return
	var numSpawners:int = spawnsParent.get_child_count()
	for _i in range(0, numSpawners):
		_spawners.push_back(spawnsParent.get_child(_i))
	
	if useSubset:
		set_all_spawner_destinations(cardinalTransforms)
	else:
		set_all_spawner_destinations(allTransforms)

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
		_spawners[i].on_trigger("", ZqfUtils.EMPTY_DICT)

func on_trigger(_msg:String, _params:Dictionary) -> void:
	_active = true
	print("Survival start")
	start_wave_spawners()

func append_state(_dict:Dictionary) -> void:
	_dict.active = _active

func restore_state(data:Dictionary) -> void:
	_active = data.active
