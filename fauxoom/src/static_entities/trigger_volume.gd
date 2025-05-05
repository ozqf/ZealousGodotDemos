extends Node3D
class_name TriggerVolume

const Enums = preload("res://src/enums.gd")

signal trigger()

@onready var _ent:Entity = $Entity
@onready var _collider:CollisionShape3D = $CollisionShape

export(Enums.TriggerVolumeAction) var action = Enums.TriggerVolumeAction.TriggerTargets
@export var triggerTargetName:String = ""
# if 0 or negative - no reset
@export var resetSeconds:float = 0
@export var valueParameter1:int = 0
@export var active:bool = true
# purely for debugging so volume can be visualised
@export var noAutoHide:bool = false
@export var hintMessage:String = ""
@export var touchDamage:int = 0

var _targetTags:EntTagSet = null
@export var triggerMessage:String = ""

var _resetTick:float = 0

func _ready() -> void:
	var _result = self.connect("body_entered", self, "_on_body_entered")
	_result = _ent.connect("entity_append_state", self, "append_state")
	_result = _ent.connect("entity_restore_state", self, "restore_state")
	_result = _ent.connect("entity_trigger", self, "on_trigger")
	_ent.selfName = name
	_ent.triggerTargetName = triggerTargetName
	_targetTags = Game.new_tag_set()
	# refresh collider disabled
	set_active(active)

func append_state(_dict:Dictionary) -> void:
	_dict.xform = ZqfUtils.transform_to_dict(global_transform)
	_dict.a = action
	_dict.active = active
	_dict.tick = _resetTick
	_dict.rs = resetSeconds
	_dict.vp1 = valueParameter1
	_dict.nah = noAutoHide
	_dict.hm =  hintMessage
	_dict.dt = touchDamage
	_dict.msg = triggerMessage
	_targetTags.write_to_dict_field(_dict, "tarTags")

func restore_from_editor(dict:Dictionary) -> void:
	_ent.restore_state(dict)

func restore_state(data:Dictionary) -> void:
	# global_transform = ZqfUtils.transform_from_dict(data.xform)
	ZqfUtils.safe_dict_apply_transform(data, "xform", self)
	action = ZqfUtils.safe_dict_i(data, "a", 0)
	_resetTick = ZqfUtils.safe_dict_f(data, "tick", 0)
	resetSeconds = ZqfUtils.safe_dict_f(data, "rs", 0)
	valueParameter1 = ZqfUtils.safe_dict_i(data, "vp1", 0)
	noAutoHide = ZqfUtils.safe_dict_b(data, "nah", false)
	hintMessage = ZqfUtils.safe_dict_s(data, "hm", "")
	triggerMessage = ZqfUtils.safe_dict_s(data, "msg", triggerMessage)
	touchDamage = ZqfUtils.safe_dict_i(data, "td", 0)
	_targetTags.read_from_dict_field(data, "tarTags")
	set_active(data.active)

func get_editor_info() -> Dictionary:
	visible = true
	var info = _ent.get_editor_info_base()
	ZEEMain.create_field(info.fields, "tarTags", "Target Tags", "tags", _targetTags.get_csv())
	ZEEMain.create_field(info.fields, "msg", "Trigger Message", "text", triggerMessage)
	ZEEMain.create_field(info.fields, "active", "Start Active", "bool", active)
	ZEEMain.create_field(info.fields, "a", "action", "int", action)
	ZEEMain.create_field(info.fields, "rs", "Reset Seconds", "float", resetSeconds)
	ZEEMain.create_field(info.fields, "vp1", "Value Param 1", "int", valueParameter1)
	return info

func set_active(flag:bool) -> void:
	active = flag
	_collider.disabled = !active
	if Main.is_in_editor() || (noAutoHide && active):
		visible = true
	else:
		visible = false
	if !active && hintMessage != "":
		Game.show_hint_text(hintMessage)

func _process(_delta:float) -> void:
	if resetSeconds > 0 && !active:
		_resetTick += _delta
		if _resetTick >= resetSeconds:
			_resetTick = 0
			set_active(true)

func on_trigger(_msg:String, _params:Dictionary) -> void:
	if _msg == "on":
		set_active(true)
	elif _msg == "off":
		set_active(false)
	else:
		set_active(!active)
\
func _on_body_entered(_body:PhysicsBody) -> void:
	_ent.trigger()
	# if triggerTargetName != "":
	# 	Interactions.triggerTargets(get_tree(), triggerTargetName)
	_ent.trigger_tag_set(_targetTags.get_tags(), triggerMessage)
	emit_signal("trigger")
	if action == Enums.TriggerVolumeAction.TeleportSubject:
		var targetEnt = Ents.find_static_entity_by_name(_ent.triggerTargetName)
		if targetEnt == null:
			targetEnt = Ents.find_dynamic_entity_by_name(_ent.triggerTargetName)
		if targetEnt == null:
			print("Trigger teleport failed to find target '" + str(_ent.triggerTargetName) + "'")
			return
		var target:Node3D = targetEnt.get_root_node() asNode3D
		# target = find_node("teleport_destination") asNode3D
		# # for child in get_children():
		# # 	if child isNode3D:
		# # 		target = child
		# # 		break;
		# if target == null:
		# 	print("Trigger teleport has no destination")
		# # can the subject be teleported?
		# if !_body.has_method("teleport"):
		# 	print("Trigger cannot teleport subject " + _body.name)
		# 	return
		var from:Vector3 = _body.global_transform.origin
		var to:Vector3 = target.global_transform.origin
		print("Teleport subject from " + str(from) + " to " + str(to))
		_body.teleport(target.global_transform)
		if touchDamage > 0 && _body.has_method("hit"):
			var info = Game.new_hit_info()
			info.damage = touchDamage
			info.damageType = Interactions.DAMAGE_TYPE_VOID
			info.attackTeam = Interactions.TEAM_NONE
			info.origin = _body.global_transform.origin - Vector3(0, 1, 0)
			info.direction = Vector3.UP
			_body.hit(info)
	else:
		set_active(false)
