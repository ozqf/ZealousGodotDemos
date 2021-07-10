extends Spatial

export var curve:Curve = null
export var lifeTime:float = 0.5

var _time:float = 0
var _dead:bool = false
var _baseScale:Vector3 = Vector3(1, 1, 1)

func _ready() -> void:
	_baseScale = scale

func _process(_delta:float):
	if _dead:
		return
	_time += _delta
	if _time > lifeTime:
		_dead = true
		queue_free()
	var _lerp:float = _time / lifeTime
	var mul:float = curve.interpolate(_lerp)
	scale = Vector3(_baseScale.x * mul, _baseScale.y * mul, _baseScale.z * mul)
