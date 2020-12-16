extends Node

var _tick:float = 1

func _process(_delta:float):
	_tick -= _delta
	if _tick <= 0:
		self.queue_free()
