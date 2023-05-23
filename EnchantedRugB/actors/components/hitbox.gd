extends Area3D
class_name HitBox

signal health_depleted

#@onready var _area:Area3D = $Area3D

@export var teamId:int = 0 
@export var initialHealth:int = 50
var _health:int = 50
var _dead:bool = false;

func _ready() -> void:
	_health = initialHealth

func _die() -> void:
	_dead = true
	self.emit_signal("health_depleted")

func hit(hitInfo:HitInfo) -> int:
	if _dead:
		return -1
	if (hitInfo.teamId == teamId):
		return -1
	_health -= hitInfo.damage
	if _health <= 0:
		_die()
		return hitInfo.damage
	return hitInfo.damage
