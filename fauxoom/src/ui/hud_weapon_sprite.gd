extends AnimatedSprite

var _screenOrigin:Vector2
var _pushOrigin:Vector2
var _pushTime:float = 0.0

var _a:Vector2 = Vector2()
var _b:Vector2 = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	_screenOrigin = global_position
	_pushOrigin = _screenOrigin
	_pushOrigin.y += 100

func run_shoot_push() -> void:
	_pushTime = 0.0
	_a = _pushOrigin
	_b = _screenOrigin
	position = _a

func _process(_delta:float):
	_pushTime += _delta
	if _pushTime > 1.0:
		_pushTime = 1.0
	position = _a.linear_interpolate(_b, _pushTime)
	pass
