extends Node3D

@onready var _loop:Node3D = $MeshInstance3D

func _process(_delta:float) -> void:
	var rot:Vector3 = _loop.rotation_degrees
	rot.y += 2 * _delta
	_loop.rotation_degrees = rot
