extends Node

onready var _head:Spatial = $head
onready var _torso:Spatial = $torso

var _tick:float = 0

func _process(_delta:float):
	var tar:Dictionary = Main.get_target()
	if tar.valid == false:
		return
	_head.look_at(tar.position, Vector3.UP)
	_torso.rotation_degrees.y = _head.rotation_degrees.y
