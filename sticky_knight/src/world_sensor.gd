extends Area2D
class_name WorldSensor

var _areaCount:int = 0
var _bodyCount:int = 0

func _ready():
	connect("body_entered", self, "_on_body_enter")
	connect("body_exited", self, "_on_body_exit")
	connect("area_entered", self, "_on_area_enter")
	connect("area_exited", self, "_on_area_exit")
	_refreshColour()
	pass

func on():
	return (_areaCount + _bodyCount) > 0

func _refreshColour():
	if on():
		$Sprite.self_modulate = Color(1, 1, 1, 1)
	else:
		$Sprite.self_modulate = Color(0, 0, 0, 1)

func _on_body_enter(_body:PhysicsBody2D):
	_bodyCount += 1
	_refreshColour()

func _on_body_exit(_body:PhysicsBody2D):
	_bodyCount -= 1
	_refreshColour()

func _on_area_enter(_area):
	_areaCount += 1
	_refreshColour()

func _on_area_exit(_area:Area2D):
	_areaCount -= 1
	_refreshColour()
