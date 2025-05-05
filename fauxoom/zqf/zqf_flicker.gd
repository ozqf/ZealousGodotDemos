extends Node3D

var _mode:int = 0
var _tick:float = 0.0

func _process(_delta) -> void:
	if _tick <= 0:
		visible = !visible
		if visible:
			_tick = randf_range(0.3, 1.5)
		else:
			_tick = randf_range(0.05, 0.2)
	else:
		_tick -= _delta
