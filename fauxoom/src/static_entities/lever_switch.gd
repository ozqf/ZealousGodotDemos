extends Spatial

onready var _off:Spatial = $off
onready var _on:Spatial = $on
onready var _shape:CollisionShape = $CollisionShape

export var on:bool = false
export var triggerTargetName:String = ""

var _state:Dictionary

func _ready() -> void:
	add_to_group(Groups.GAME_GROUP_NAME)
	_state = _write_state()

func game_on_reset() -> void:
	_read_state(_state)

func _write_state() -> Dictionary:
	return {
		on = on
	}

func _read_state(data:Dictionary) -> void:
	_state = data
	_set_on(_state.on)

func _set_on(flag:bool) -> void:
	on = flag
	_off.visible = !on
	_on.visible = on
	_shape.disabled = on

func use() -> void:
	if !on:
		_set_on(true)
		Interactions.triggerTargets(get_tree(), triggerTargetName)
