extends Node3D

@export var degreesPerSecond:float = -12

func _process(_delta:float) -> void:
	var rot:Vector3 = self.rotation_degrees
	rot.y += degreesPerSecond * _delta
	self.rotation_degrees = rot
