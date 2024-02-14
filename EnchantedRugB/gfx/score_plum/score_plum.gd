extends Node3D

var _duration:float = 3.0
var _tick:float = 0.0

func _process(delta):
	if _tick > _duration:
		self.set_process(false)
		self.queue_free()
	self.global_position.y += (3 * delta)
	_tick += delta
	var weight:float = _tick / _duration
	var s:Vector3 = Vector3(1, 1, 1).lerp(Vector3(0, 0, 0), weight)
	self.scale = s
