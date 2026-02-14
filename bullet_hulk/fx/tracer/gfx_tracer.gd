extends Node3D
class_name GFXTracer

var _a:Vector3
var _b:Vector3
var _tick:float = 0.0
var _time:float = 1.0

func launch_tracer(a:Vector3, b:Vector3, speed:float = 250, size:float = 1.0) -> void:
	_a = a
	_b = b
	self.global_position = _a
	self.look_at(_b)
	self.scale = Vector3(size, size, size)
	var dist:float = (_b - _a).length()
	_time = dist / speed

func _process(_delta:float) -> void:
	_tick += _delta
	if _tick > _time:
		self.queue_free()
		return
	var weight:float = _tick / _time
	self.global_position = _a.lerp(_b, weight)
