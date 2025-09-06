extends Node3D

const mph_100_in_metres_per_second:float = 44.702

var _a:Vector3 = Vector3(0, 0, -300)
var _b:Vector3 = Vector3(0, 0, 300)
var _speed:float = 80.0
var _travelled:float = 0.0

func _ready() -> void:
	var p:Vector3 = self.global_position
	_a.x = p.x
	_a.y = p.y
	_b.x = p.x
	_b.y = p.y
	_travelled = self.global_position.distance_to(_a)

func _process(_delta: float) -> void:
	var dist:float = _a.distance_to(_b)
	var time:float = dist / _speed
	_travelled += _speed * _delta
	if _travelled >= dist:
		_travelled -= dist
	var weight:float = _travelled / dist
	var p:Vector3 = _a.lerp(_b, weight)
	self.global_position = p
	pass
