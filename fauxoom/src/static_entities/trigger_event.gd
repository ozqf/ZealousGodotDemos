extends Spatial

export var selfName:String = ""
export var triggerTargetName:String = ""
export var active:bool = true

enum EventType {
	None = 0,
	LevelComplete = 1,
}

export(EventType) var type = EventType.None

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
