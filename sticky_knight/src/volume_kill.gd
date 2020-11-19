extends Area2D

func _ready():
	connect("body_entered", self, "on_body_enter")
	pass

func on_body_enter(_body):
	if _body.has_method("kill"):
		_body.kill()
