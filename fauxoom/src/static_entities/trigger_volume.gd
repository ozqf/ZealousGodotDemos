extends Spatial

onready var _ent:Entity = $Entity
onready var _collider:CollisionShape = $CollisionShape

export var triggerTargetName:String = ""
# if 0 or negative - no reset
export var resetSeconds:float = 0
export var active:bool = true
# purely for debugging so volume can be visualised
export var noAutoHide:bool = false

var _resetTick:float = 0

func _ready() -> void:
	var _result = self.connect("body_entered", self, "_on_body_entered")
	_result = _ent.connect("entity_append_state", self, "append_state")
	_result = _ent.connect("entity_restore_state", self, "restore_state")
	_result = _ent.connect("entity_trigger", self, "on_trigger")
	_ent.selfName = name
	# refresh collider disabled
	set_active(active)

func set_active(flag:bool) -> void:
	active = flag
	_collider.disabled = !active
	if noAutoHide && active:
		visible = true
	else:
		visible = false

func _process(_delta:float) -> void:
	if resetSeconds > 0 && !active:
		_resetTick += _delta
		if _resetTick >= resetSeconds:
			_resetTick = 0
			set_active(true)

func append_state(_dict:Dictionary) -> void:
	_dict.selfName = name
	_dict.triggerTargetName = triggerTargetName
	_dict.active = active
	_dict.tick = _resetTick

func restore_state(data:Dictionary) -> void:
	name = data.selfName
	triggerTargetName = data.triggerTargetName
	_resetTick = data.tick
	set_active(data.active)

func on_trigger() -> void:
	set_active(!active)

func _on_body_entered(_body:PhysicsBody) -> void:
	if triggerTargetName != "":
		Interactions.triggerTargets(get_tree(), triggerTargetName)
	set_active(false)
