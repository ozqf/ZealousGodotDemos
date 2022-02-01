extends Spatial

export var running:bool = true
export var duration:float = 1.0
export var destination:Vector3 = Vector3()

var _origin:Vector3

var _dir:float = 1
var _time:float = 0

func _ready():
	_origin = transform.origin

func _process(_delta:float) -> void:
	if !running:
		return
	if _dir > 0:
		_time += _delta
		if _time > duration:
			_time = duration
			_dir = -1
	else:
		_time -= _delta
		if _time < 0:
			_time = 0
			_dir = 1
	var weight:float = _time / duration
	transform.origin = _origin.linear_interpolate(destination, weight)
