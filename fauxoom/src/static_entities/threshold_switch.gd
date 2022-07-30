extends Spatial

enum ThresholdSwitchState {
	Active,
	Complete
}

onready var _hitBox:Spatial = $hitbox
onready var _ent:Entity = $Entity
onready var _particles = $Particles

var _state = ThresholdSwitchState.Active
var _damageTally:float = 0
var _threshold:float = 400.0
var _recoverSeconds:float = 3.0

var _resetSeconds:float = 10.0
var _resetTick:float = 0.0

func _ready() -> void:
	_hitBox.set_subject(self)
	_ent.connect("entity_restore_state", self, "_restore_state")
	_ent.connect("entity_append_state", self, "_append_state")
	_ent.connect("entity_trigger", self, "_trigger")

func _restore_state(_dict:Dictionary) -> void:
	ZqfUtils.safe_dict_apply_transform(_dict, "xform", self)

func _append_state(_dict:Dictionary) -> void:
	_dict.xform = ZqfUtils.transform_to_dict(self.global_transform)

func _trigger(_msg:String, _dict:Dictionary) -> void:
	pass

func _refresh_position() -> void:
	var weight:float = _damageTally / _threshold
	if weight > 1:
		weight = 1
	if weight < 0:
		weight = 0
	var pos:Vector3 = Vector3().linear_interpolate(Vector3(0, 0, -2), weight)
	_hitBox.transform.origin = pos

func _set_complete() -> void:
	_particles.emitting = true
	_damageTally = _threshold
	_state = ThresholdSwitchState.Complete
	_resetTick = _resetSeconds
	_refresh_position()

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
	_damageTally += float(_hitInfo.damage)
	if _damageTally > _threshold:
		_set_complete()
	print("Threshold switch hit " + str(_damageTally))
	return _hitInfo.damage
