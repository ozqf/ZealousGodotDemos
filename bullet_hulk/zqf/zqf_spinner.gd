extends Node3D

@export var degreesPerSecond:Vector3 = Vector3()
@export var spinning:bool = false

func _process(_delta: float) -> void:
	var spin:Vector3 = degreesPerSecond * _delta
	var rot:Vector3 = self.rotation_degrees
	rot += spin
	self.rotation_degrees = rot
