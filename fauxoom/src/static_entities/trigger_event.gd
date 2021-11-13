extends Spatial

export var selfName:String = ""
export var triggerTargetName:String = ""
export var active:bool = true

enum EventType {
	None = 0,
	LevelComplete = 1,
	ActivateWaypointTag = 2,
	DeactivateWaypointTag = 3
}

export(EventType) var type = EventType.None
export var intParameter1:int = 0

var _spawnState:Dictionary = {}

func _ready() -> void:
	add_to_group(Groups.ENTS_GROUP_NAME)
	add_to_group(Groups.GAME_GROUP_NAME)
	visible = false
	_spawnState = write_state()

func write_state() -> Dictionary:
	return {
		selfName = selfName,
		triggerTargetName = triggerTargetName,
		active = active
	}

func restore_state(data:Dictionary) -> void:
	selfName = data.selfName
	triggerTargetName = data.triggerTargetName
	active = data.active

func game_on_reset() -> void:
	restore_state(_spawnState)

func on_trigger_entities(target:String) -> void:
	if target == "" || target != selfName:
		return
	
	if type == EventType.LevelComplete:
		get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_LEVEL_COMPLETED)
	elif type == EventType.ActivateWaypointTag:
		AI.activate_waypoint_tag(intParameter1)
	elif type == EventType.DeactivateWaypointTag:
		AI.deactivate_waypoint_tag(intParameter1)
	else:
		print("Trigger event has invalid type set: " + str(int(type)))
