extends Spatial

onready var _ent:Entity = $Entity

export var selfName:String = ""
export var triggerTargetName:String = ""
export var active:bool = true

export var totalCount:int = 1

var _currentCount:int = 0

func _ready() -> void:
	visible = false
	var _r = _ent.connect("entity_append_state", self, "append_state")
	_r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_trigger", self, "on_trigger")
	_ent.selfName = selfName
	_ent.triggerTargetName = triggerTargetName

func append_state(_dict:Dictionary) -> void:
	_dict.selfName = selfName
	_dict.triggerTargetName = triggerTargetName
	_dict.active = active
	_dict.totalCount = totalCount
	_dict.currentCount = _currentCount

func restore_state(data:Dictionary) -> void:
	selfName = data.selfName
	triggerTargetName = data.triggerTargetName
	active = data.active
	totalCount = data.totalCount
	_currentCount = data.currentCount

func on_trigger() -> void:
	_currentCount += 1
	if _currentCount >= totalCount:
		active = false
		Interactions.triggerTargets(get_tree(), triggerTargetName)
