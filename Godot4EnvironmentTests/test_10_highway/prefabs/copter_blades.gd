extends Node3D

@onready var degreesPerSecond:float = 1200

func _process(_delta:float) -> void:
	var rot:Vector3 = rotation_degrees
	rot.y += degreesPerSecond * _delta
	rotation_degrees = rot
