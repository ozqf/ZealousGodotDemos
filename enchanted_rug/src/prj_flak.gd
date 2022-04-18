extends Node

var _state:int = 0
var _tick:float = 0.0

func _process(_delta:float) -> void:
	if _state == 0:
		_tick += _delta
		if _tick > 2.0:
			_state = 1
			self.queue_free()

func prj_launch(_pos:Vector3, _dir:Vector3, _spinStartDegrees:float = 0, _spinRateDegrees:float = 0) -> void:
	# global_transform.origin = 
	pass
