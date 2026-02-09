extends Node3D

var _tick:float = 0.0

func _physics_process(delta: float) -> void:
	_tick += delta
	if _tick > 1.0:
		self.queue_free()
