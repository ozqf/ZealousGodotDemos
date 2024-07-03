extends Area2D

var _player:Node2D = null

func _ready():
	var _c1 = connect("body_entered", Callable(self, "on_body_enter"))
	var _c2 = connect("body_exited", Callable(self, "on_body_exit"))
	_player = get_parent()

func on_body_enter(_body):
	if _body.has_method("found_player"):
		_body.found_player(_player)

func on_body_exit(_body):
	if _body.has_method("lost_player"):
		_body.lost_player(_player)
