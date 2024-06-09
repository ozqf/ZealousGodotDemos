extends MobBase

var _bounceTick:float = 1.0
var _bounceTime:float = 1.0

var _bounceDisplayT:Transform3D
var _originDisplayT:Transform3D

func _ready() -> void:
	_originDisplayT = _display.transform

func hit(_hitInfo) -> int:
	print("Mob dummy hit")
	_bounceTick = 0.0
	_bounceTime = 0.5
	_bounceDisplayT = _originDisplayT
	_bounceDisplayT = _bounceDisplayT.rotated(Vector3.RIGHT, deg_to_rad(45.0))
	return 0

func _process(_delta:float) -> void:
	_bounceTick += _delta
	_bounceTick = clampf(_bounceTick, 0, _bounceTime)
	var weight:float = _bounceTick / _bounceTime
	_display.transform = _bounceDisplayT.interpolate_with(_originDisplayT, weight)
	pass
