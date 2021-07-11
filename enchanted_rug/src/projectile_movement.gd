extends Node
class_name ProjectileMovement

export var speed:float = 1
export var minSpeed:float = 1
export var maxSpeed:float = 100
export var acceleration:float = 25
export var spinRateDegrees:float = 22.5

func apply_to(other) -> void:
	other.speed = speed
	other.minSpeed = minSpeed
	other.maxSpeed = maxSpeed
	other.acceleration = acceleration
	other.spinRateDegrees = spinRateDegrees
