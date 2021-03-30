extends Spatial


export var selfName:String = ""
export var triggerTargetName:String = ""
export var active:bool = true

export var totalCount:int = 1

var _currentCount:int = 0

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
		active = active,
		totalCount = totalCount,
		currentCount = _currentCount
	}

func restore_state(data:Dictionary) -> void:
	selfName = data.selfName
	triggerTargetName = data.triggerTargetName
	active = data.active
	totalCount = data.totalCount
	_currentCount = data.currentCount

func game_on_reset() -> void:
	restore_state(_spawnState)

func on_trigger_entities(target:String) -> void:
	if !active:
		return
	if target == "" || target != selfName:
		return
	
	_currentCount += 1
	if _currentCount >= totalCount:
		active = false
		Interactions.triggerTargets(get_tree(), triggerTargetName)
