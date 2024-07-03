extends Area2D
class_name SpikeBall

func _ready():
	var _foo = connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(_body):
	if _body.has_method("touch_spike"):
		_body.touch_spike(self)
