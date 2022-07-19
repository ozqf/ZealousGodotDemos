extends Spatial

onready var _ent:Entity = $Entity
onready var _area:Area = $Area
onready var _coreSprite:AnimatedSprite3D = $Area/core_sprite
onready var _light:OmniLight = $OmniLight

export var on:bool = false
export var activeSeconds:float = 4.0
export var onTriggerMessage:String = ""
export var offTriggerMessage:String = ""
var _tick:float = 0.0

var _onTags:EntTagSet
var _offTags:EntTagSet

func _ready() -> void:
	var _err = _ent.connect("entity_restore_state", self, "restore_state")
	_err = _ent.connect("entity_append_state", self, "append_state")
	_err = _area.connect("body_entered", self, "on_body_entered")
	_onTags = Game.new_tag_set()
	_offTags = Game.new_tag_set()
	set_on(false)

func get_editor_info() -> Dictionary:
	visible = true
	var info = _ent.get_editor_info_base()
	ZEEMain.create_field(info.fields, "onMsg", "On Message", "text", onTriggerMessage)
	ZEEMain.create_field(info.fields, "onTags", "On Tags", "tags", _onTags.get_csv())
	ZEEMain.create_field(info.fields, "offMsg", "Off Message", "text", offTriggerMessage)
	ZEEMain.create_field(info.fields, "offTags", "Off Tags", "tags", _offTags.get_csv())
	return info

func restore_from_editor(dict:Dictionary) -> void:
	_ent.restore_state(dict)

func append_state(_dict:Dictionary) -> void:
	_dict.on = on
	_dict.xform = ZqfUtils.transform_to_dict(self.global_transform)
	_dict.asec = activeSeconds
	_dict.tick = _tick
	_dict.onTags = _onTags.get_csv()
	_dict.offTags = _offTags.get_csv()
	_dict["onMsg"] = onTriggerMessage
	_dict["offMsg"] = offTriggerMessage

func restore_state(data:Dictionary) -> void:
	activeSeconds = ZqfUtils.safe_dict_f(data, "asec", activeSeconds)
	_tick = ZqfUtils.safe_dict_f(data, "tick", activeSeconds)
	set_on(ZqfUtils.safe_dict_b(data, "on", false))
	ZqfUtils.safe_dict_apply_transform(data, "xform", self)
	_onTags.read_from_dict_field(data, "onTags")
	_offTags.read_from_dict_field(data, "offTags")
	onTriggerMessage = ZqfUtils.safe_dict_s(data, "onMsg", onTriggerMessage)
	offTriggerMessage = ZqfUtils.safe_dict_s(data, "offMsg", offTriggerMessage)

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
		var targets = _onTags.get_tags()
		Interactions.triggerTargetsWithParams(get_tree(), targets, onTriggerMessage, ZqfUtils.EMPTY_DICT)
	else:
		_light.light_color = Color.green
		var targets = _offTags.get_tags()
		Interactions.triggerTargetsWithParams(get_tree(), targets, offTriggerMessage, ZqfUtils.EMPTY_DICT)

func _process(_delta:float) -> void:
	if !on:
		return
	if _tick <= 0.0:
		_tick = activeSeconds
		set_on(false)
	else:
		_tick -= _delta
