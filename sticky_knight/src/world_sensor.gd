extends Area2D
class_name WorldSensor

var _areaCount:int = 0
var _bodyCount:int = 0
var _parent = null

func _ready():
	var _c1 = connect("body_entered", self, "_on_body_enter")
	var _c2 = connect("body_exited", self, "_on_body_exit")
	var _c3 = connect("area_entered", self, "_on_area_enter")
	var _c4 = connect("area_exited", self, "_on_area_exit")
	_refreshColour()
	_parent = get_parent()
	pass

func on():
	return (_areaCount + _bodyCount) > 0

func _refreshColour():
	if on():
		$Sprite.self_modulate = Color(1, 1, 1, 1)
	else:
		$Sprite.self_modulate = Color(0, 0, 0, 1)

func _on_body_enter(_body:PhysicsBody2D):
	if _body == _parent:
		return
	_bodyCount += 1
	_refreshColour()

func _on_body_exit(_body:PhysicsBody2D):
	if _body == _parent:
		return
	_bodyCount -= 1
	_refreshColour()

func _on_area_enter(_area):
	if _area == _parent:
		return
	_areaCount += 1
	_refreshColour()

func _on_area_exit(_area:Area2D):
	if _area == _parent:
		return
	_areaCount -= 1
	_refreshColour()
