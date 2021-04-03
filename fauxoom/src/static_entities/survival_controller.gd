extends Spatial

var _mob_punk_t = preload("res://prefabs/dynamic_entities/mob_punk.tscn")

export var selfName:String = ""
export var triggerTargetName:String = ""

var _state:Dictionary
var _active:bool = false

var _spawnTransforms = []

func _ready() -> void:
	visible = false
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.ENTS_GROUP_NAME)
	_state = write_state()
	var spawnPoints:Spatial = get_node("spawn_points")
	var numPoints:int = spawnPoints.get_child_count()
	for _i in range(0, numPoints):
		_spawnTransforms.push_back(spawnPoints.get_child(_i).global_transform)

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

func write_state() -> Dictionary:
	return {
		
	}

func restore_state(data:Dictionary) -> void:
	_state = data
