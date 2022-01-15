extends Area
class_name OrbShield

signal shield_broke(index)
signal shield_restored(index)

onready var _shape:CollisionShape = $CollisionShape

var index:int = 0
var _state:int = 0
var _health:int = 100

func _ready():
	pass # Replace with function body.

func hit(_hitInfo:HitInfo) -> int:
	if _state == 1:
		return Interactions.HIT_RESPONSE_PENETRATE
	# only permit certain damage types
	if !_hitInfo.damageType == Interactions.DAMAGE_TYPE_PLASMA:
		return Interactions.HIT_RESPONSE_NONE
	_health -= _hitInfo.damage
	# print("Hit shield orb")
	if _health <= 0:
		_state = 1
		visible = false
		_shape.disabled = true
		emit_signal("shield_broke", index)
	return _hitInfo.damage
