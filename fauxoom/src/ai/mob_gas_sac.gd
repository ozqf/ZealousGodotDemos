extends KinematicBody

var _speed:float = 5.0

var _velocity:Vector3 = Vector3()

func _ready() -> void:
	_velocity = (Vector3.UP * _speed)

func _process(_delta:float) -> void:
	var plyr:Dictionary = AI.get_player_target()
	if !plyr:
		return
	
	var turnMul:float = _delta * 2.0
	var tarPos:Vector3 = plyr.position
	var pos:Vector3 = global_transform.origin
	var toward:Vector3 = (tarPos - pos).normalized()
	var dir:Vector3 = _velocity.normalized()
	var newDir:Vector3 = (dir + (toward * turnMul)).normalized()
	_velocity = newDir * _speed
	_velocity = move_and_slide(_velocity)

func hit(_hitInfo:HitInfo) -> int:
	if _hitInfo.attackTeam == Interactions.TEAM_ENEMY:
		return Interactions.HIT_RESPONSE_NONE
	queue_free()
	return _hitInfo.damage
