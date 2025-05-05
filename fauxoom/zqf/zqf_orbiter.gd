extends Node3D

@export var running:bool = true
@export var degreesPerSecond:Vector3 = Vector3()

var _rot:Vector3 = Vector3()

func _process(_delta):
	if !running:
		return
#	_rot.x += degreesPerSecond.x * _delta
	_rot.y += degreesPerSecond.y * _delta
#	_rot.z += degreesPerSecond.z * _delta
	rotation_degrees = _rot
