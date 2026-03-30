extends Node3D

var _speed:float = 15.0
var _time:float = 0.0

func launch(origin:Vector3, dir:Vector3, spd:float, rollDegrees:float = 0.0) -> void:
	self.global_position = origin
	self.look_at(origin + dir)
	if !is_zero_approx(rollDegrees):
		var deg:Vector3 = self.rotation_degrees
		deg.z = rollDegrees
		self.rotation_degrees = deg
	_speed = spd

func _process(_delta: float) -> void:
	_time += _delta
	if _time > 25.0:
		self.queue_free()
		_time = 0.0
		return
	var t:Transform3D = self.global_transform
	self.global_position += (-t.basis.z * _speed) * _delta
	pass
