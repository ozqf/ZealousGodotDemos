extends Spatial

onready var _ent:Entity = $Entity
onready var _area:Area = $Area
onready var _coreSprite:AnimatedSprite3D = $Area/core_sprite
onready var _light:OmniLight = $OmniLight

export var on:bool = false
export var activeSeconds:float = 4.0
var _tick:float = 0.0

func _ready() -> void:
	var _err = _ent.connect("entity_restore_state", self, "restore_state")
	_err = _ent.connect("entity_append_state", self, "append_state")
	_err = _area.connect("body_entered", self, "on_body_entered")
	set_on(false)

func get_editor_info() -> Dictionary:
	visible = true
	var info = _ent.get_editor_info_base()
	return info

func append_state(_dict:Dictionary) -> void:
	_dict.on = on
	_dict.xform = ZqfUtils.transform_to_dict(self.global_transform)
	_dict.asec = activeSeconds
	_dict.tick = _tick

func restore_state(data:Dictionary) -> void:
	activeSeconds = ZqfUtils.safe_dict_f(data, "asec", activeSeconds)
	_tick = ZqfUtils.safe_dict_f(data, "tick", activeSeconds)
	set_on(ZqfUtils.safe_dict_b(data, "on", false))
	ZqfUtils.safe_dict_apply_transform(data, "xform", self)

func on_body_entered(body) -> void:
	# print("Body touched core receptacle: " + str(body))
	if !on && body.has_method("core_collect"):
		body.core_collect()
		set_on(true)
	pass

func is_core_receptacle() -> bool:
	return true

func set_on(flag:bool) -> void:
	on = flag
	_coreSprite.visible = flag
	if on:
		_tick = activeSeconds
		_light.light_color = Color.yellow
	else:
		_light.light_color = Color.green

func _process(_delta:float) -> void:
	if !on:
		return
	if _tick <= 0.0:
		_tick = activeSeconds
		set_on(false)
	else:
		_tick -= _delta
