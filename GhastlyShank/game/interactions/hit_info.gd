extends Node
class_name HitInfo

var teamId:int = 0
var damage:float = 1.0
var launchYawRadians:float = 0.0
var juggleStrength:float = 0.0
var launchStrength:float = 0.0
var sweepStrength:float = 0.0
var flinchStrength:float = 1.0
var hitHeight:int = 1

func reset() -> void:
	damage = 1.0
	juggleStrength = 0.0
	launchStrength = 0.0
	sweepStrength = 0.0
