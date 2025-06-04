extends AnimationPlayer
class_name ModelHitJitter

@export var hitKnockbackWeight:float = 1.0

var _tick:float = 0.0
var _time:float = 0.0

var _localKnockbackDir:Vector3 = Vector3.BACK

func _process(delta:float) -> void:
	_time += delta
	#var s:float = sin(_time * 10)
	#s += 1
	#s /= 2
	#var weight:float = 0.0
	get_parent().position = _localKnockbackDir * (0.8 * hitKnockbackWeight)
	pass

func runHitKnockback(_dir:Vector3) -> void:
	var gPos:Vector3 = get_parent().global_position
	var gOffset:Vector3 = gPos + _dir
	_localKnockbackDir = _dir
	play("knockback")
