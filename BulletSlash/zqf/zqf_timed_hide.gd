extends Node3D
class_name ZqfTimedHide3D

@export var tick:float = 2.0
@export var affectParent:bool = false

func _get_subject() -> Node3D:
	if affectParent:
		return self.get_parent()
	else:
		return self

func run(time:float = 0.2) -> void:
	_get_subject().visible = true
	tick = time

func _process(delta):
	tick -= delta
	if tick <= 0.0:
		tick = 9999999
		_get_subject().visible = false
