extends Spatial

export var selfName:String = ""
export var triggerTargetName:String = ""
export var active:bool = true

var _spawnState:Dictionary = {}

func _ready() -> void:
	visible = false
	add_to_group(Groups.ENTS_GROUP_NAME)
	self.connect("body_entered", self, "_on_body_entered")
	add_to_group(Groups.GAME_GROUP_NAME)

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
	print("Trigger volume saw game reset")
	restore_state(_spawnState)

func on_trigger_entities(target:String) -> void:
	if target == "":
		return
	if target == selfName:
		active = !active

func _on_body_entered(_body:PhysicsBody) -> void:
	if !active:
		return
	if triggerTargetName == "":
		return
	# print("Volume - trigger target '" + triggerTargetName + "'")
	Interactions.triggerTargets(get_tree(), triggerTargetName)
	# get_tree().call_group("entities", "on_trigger_entities", triggerTargetName)
	active = false
