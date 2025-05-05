extends Node3D

enum ThresholdSwitchState {
	Active,
	Complete
}

@onready var _hitBox:Node3D = $hitbox
@onready var _ent:Entity = $Entity
@onready var _particles = $Particles

var _state = ThresholdSwitchState.Active
var _damageTally:float = 0
var _threshold:float = 400.0
var _recoverSeconds:float = 3.0
var _tags:EntTagSet

var _resetSeconds:float = 8.0
var _resetTick:float = 0.0

func _ready() -> void:
	_hitBox.set_subject(self)
	_tags = Game.new_tag_set()
	_ent.connect("entity_restore_state", self, "_restore_state")
	_ent.connect("entity_append_state", self, "_append_state")
	_ent.connect("entity_trigger", self, "_trigger")

func _append_state(_dict:Dictionary) -> void:
	_dict.xform = ZqfUtils.transform_to_dict(self.global_transform)
	_dict.state = _state
	_dict.dmg = _threshold
	_dict.tags = _tags.get_csv()
	_dict.tick = _resetTick
	_dict.wait = _resetSeconds

func _restore_state(_dict:Dictionary) -> void:
	ZqfUtils.safe_dict_apply_transform(_dict, "xform", self)
	_state = ZqfUtils.safe_dict_i(_dict, "state", _state)
	_tags.read_csv(ZqfUtils.safe_dict_s(_dict, "tags", _tags.get_csv()))
	_threshold = ZqfUtils.safe_dict_f(_dict, "dmg", _threshold)
	_resetTick = ZqfUtils.safe_dict_f(_dict, "tick", _resetTick)
	_resetSeconds = ZqfUtils.safe_dict_f(_dict, "wait", _resetSeconds)

func restore_from_editor(dict:Dictionary) -> void:
	_ent.restore_state(dict)

func get_editor_info() -> Dictionary:
	var info = _ent.get_editor_info_base()
	ZEEMain.create_field(info.fields, "tags", "Targets", "tags", _tags.get_csv())
	ZEEMain.create_field(info.fields, "dmg", "Damage threshold", "int", int(_threshold))
	ZEEMain.create_field(info.fields, "wait", "Reset Seconds", "float", _resetSeconds)
	return info

func _trigger(_msg:String, _dict:Dictionary) -> void:
	pass

func _refresh_position() -> void:
	var weight:float = _damageTally / _threshold
	if weight > 1:
		weight = 1
	if weight < 0:
		weight = 0
	var pos:Vector3 = Vector3(0, 0, 2).linear_interpolate(Vector3(0, 0, 0), weight)
	_hitBox.transform.origin = pos

func _set_complete() -> void:
	_particles.emitting = true
	_damageTally = _threshold
	_state = ThresholdSwitchState.Complete
	_resetTick = _resetSeconds
	_refresh_position()
	_ent.trigger_tag_set(_tags.get_tags(), "")

func _set_active() -> void:
	_damageTally = 0
	_state = ThresholdSwitchState.Active
	_refresh_position()

func _process(_delta:float) -> void:
	if _state == ThresholdSwitchState.Active:
		var step:float = _threshold * (1 / _recoverSeconds * _delta)
		_damageTally -= step
		if _damageTally < 0.0:
			_damageTally = 0.0
		_refresh_position()
	else:
		if _resetSeconds <= 0.0:
			return
		_resetTick -= _delta
		if _resetTick <= 0.0:
			_set_active()

func hit(_hitInfo:HitInfo) -> int:
	if _state == ThresholdSwitchState.Complete:
		return Interactions.HIT_RESPONSE_NONE
	if _hitInfo.hyperLevel > 0:
		return Interactions.HIT_RESPONSE_ABSORBED
	_damageTally += float(_hitInfo.damage)
	if _damageTally > _threshold:
		_set_complete()
	# print("Threshold switch hit " + str(_damageTally))
	return _hitInfo.damage
