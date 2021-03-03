extends Spatial

export var selfName:String = ""
export var triggerTargetName:String = ""

var _active:bool = true

func _ready() -> void:
	add_to_group(Groups.ENTS_GROUP_NAME)
	self.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(_body:PhysicsBody) -> void:
	if !_active:
		return
	if triggerTargetName == "":
		return
	print("Volume - trigger target '" + triggerTargetName + "'")
	get_tree().call_group("entities", "on_trigger_entities", triggerTargetName)
	_active = false
