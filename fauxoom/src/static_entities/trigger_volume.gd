extends Spatial

onready var _ent:Entity = $Entity

export var selfName:String = ""
export var triggerTargetName:String = ""
export var active:bool = true

func _ready() -> void:
	visible = false
	var _result = self.connect("body_entered", self, "_on_body_entered")
	_result = _ent.connect("entity_append_state", self, "append_state")
	_result = _ent.connect("entity_restore_state", self, "restore_state")
	_result = _ent.connect("entity_trigger", self, "on_trigger")

func append_state(_dict:Dictionary) -> void:
	_dict.selfName = selfName
	_dict.triggerTargetName = triggerTargetName
	_dict.active = active

func restore_state(data:Dictionary) -> void:
	selfName = data.selfName
	triggerTargetName = data.triggerTargetName
	active = data.active

func on_trigger() -> void:
	active = !active

func _on_body_entered(_body:PhysicsBody) -> void:
	if !active:
		return
	if triggerTargetName == "":
		return
	Interactions.triggerTargets(get_tree(), triggerTargetName)
	active = false
