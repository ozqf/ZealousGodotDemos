extends Node

@onready var _cannons:Node3D = $cannons

var _tick:float = 0.0

func _process(_delta:float) -> void:
	_tick -= _delta
	if _tick <= 0.0:
		_tick = 4.0
		var target:Vector3 = self.global_position
		target.y += 600.0
		target.x += randf_range(-400, 400)
		target.z += randf_range(-400, 400)
		_cannons.look_at(target, Vector3.FORWARD)
		pass
