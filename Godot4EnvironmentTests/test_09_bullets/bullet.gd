extends Node3D

var velocity:Vector3 = Vector3()

var _tick:float = 0.0

func _process(_delta:float) -> void:
	self.global_position += velocity * _delta
	_tick += _delta
	if _tick > 10.0:
		_tick = 0.0
		self.queue_free()
