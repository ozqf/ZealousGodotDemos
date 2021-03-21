extends Node

onready var _mesh:MeshInstance = $MeshInstance
onready var _shape:CollisionShape = $CollisionShape

export var selfName:String = ""
export var triggerTargetName:String = ""
export var active:bool = true

var _spawnState:Dictionary = {}

func _ready() -> void:
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.ENTS_GROUP_NAME)
	set_active(active)
	_spawnState = write_state()

func set_active(flag:bool) -> void:
	active = flag
	_shape.disabled = !active
	_mesh.visible = active

func write_state() -> Dictionary:
	return {
		selfName = selfName,
		triggerTargetName = triggerTargetName,
		active = active
	}

func restore_state(data:Dictionary) -> void:
	selfName = data.selfName
	triggerTargetName = data.triggerTargetName
	set_active(data.active)

func game_on_reset() -> void:
	restore_state(_spawnState)

func on_trigger_entities(target:String) -> void:
	if target == "":
		return
	if selfName == target:
		set_active(!active)
