extends Node3D

@onready var _laser = $mob_aim_laser

var _duration:float = 4
var _tick:float = 4

func _process(delta) -> void:
	_tick -= delta
	if _tick <= 0:
		_tick = 9999999
		# _laser.on(_duration / 2, true)
		queue_free()

func run(pos:Vector3, durationSeconds:float) -> Vector3:
	_duration = durationSeconds
	_tick = _duration
	global_transform.origin = pos
	_laser.on(_duration, true)
	var result:Dictionary = ZqfUtils.hitscan_by_direction_3D(
		self,
		pos,
		Vector3.UP,
		20,
		ZqfUtils.EMPTY_ARRAY,
		Interactions.WORLD)
	if !result:
		return pos + Vector3(0, 20, 0)
	else:
		return result.position
