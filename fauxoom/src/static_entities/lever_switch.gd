extends Spatial

signal trigger()

onready var _off:Spatial = $off
onready var _on:Spatial = $on
onready var _shape:CollisionShape = $CollisionShape
onready var _ent:Entity = $Entity

export var on:bool = false
# zero or negative reset time == never reset
export var resetTime:float = -1
export var triggerTargetName:String = ""

var _resetTick:float = 0

func _ready() -> void:
	_ent.triggerTargetName = triggerTargetName
	var _err = _ent.connect("entity_restore_state", self, "restore_state")
	_err = _ent.connect("entity_append_state", self, "append_state")

func _process(_delta:float) -> void:
	if !on:
		return
	if resetTime > 0:
		_resetTick += _delta
		if _resetTick >= resetTime:
			_resetTick = 0
			_set_on(false)

func append_state(_dict:Dictionary) -> void:
	_dict.on = on
	_dict.resetTick = _resetTick

func restore_state(data:Dictionary) -> void:
	_set_on(data.on)
	_resetTick = data.resetTick

func _set_on(flag:bool) -> void:
	on = flag
	_off.visible = !on
	_on.visible = on
	_shape.disabled = on

func use() -> void:
	if !on:
		_set_on(true)
		emit_signal("trigger")
		Interactions.triggerTargets(get_tree(), triggerTargetName)
