extends Area2D

func _ready():
	connect("body_entered", self, "on_body_enter")
	pass

func on_body_enter(_body):
	if _body.has_method("touch_spring"):
		var degrees:float = rotation_degrees
		degrees -= 90
		var radians:float = deg2rad(degrees)
		var push = Vector2(cos(radians) * 1000, sin(radians) * 1000)
		_body.touch_spring(push)
