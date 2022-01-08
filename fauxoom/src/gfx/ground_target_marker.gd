extends Spatial

onready var _laser = $mob_aim_laser

var _duration:float = 4
var _tick:float = 4

func _process(delta) -> void:
	_tick -= delta
	if _tick <= 0:
		_tick = _duration
		_laser.on(_duration / 2, true)
