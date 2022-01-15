extends Spatial

export var running:bool = true
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
		if _time > 1:
			_time = 1
			_dir = -1
	else:
		_time -= _delta
		if _time < 0:
			_time = 0
			_dir = 1
	transform.origin = _origin.linear_interpolate(destination, _time)
