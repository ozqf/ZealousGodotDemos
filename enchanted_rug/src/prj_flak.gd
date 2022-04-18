extends Spatial

const STATE_IDLE:int = 0
const STATE_GROWING:int = 1
const STATE_DETONATING:int = 2
const STATE_DEAD:int = 3

var _state:int = 0
var _tick:float = 0.0
var _growTime:float = 0.5
var _targetScale:Vector3 = Vector3.ONE

func _process(_delta:float) -> void:
	if _state == STATE_GROWING:
		_tick += _delta
		var weight:float = _tick / _growTime
		weight = ZqfUtils.clamp_float(weight, 0.0, 1.0)
		self.scale = _targetScale * weight
		if _tick >= _growTime:
			_state = STATE_DETONATING
			_tick = 0.0
	elif _state == STATE_DETONATING:
		_tick += _delta
		if _tick > 2.0:
			_state = STATE_DEAD
			self.queue_free()

func prj_launch(_launchInfo:PrjLaunchInfo) -> void:
	global_transform.origin = _launchInfo.target
	_targetScale = self.scale
	_state = STATE_GROWING
	self.scale = Vector3(0, 0, 0)
	pass
