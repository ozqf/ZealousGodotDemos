extends Node

var _projectile_t = preload("res://prefabs/projectiles/prj_ball_large.tscn")

onready var _head:Spatial = $head
onready var _torso:Spatial = $torso
onready var _turret = $head/turret

var _tick:float = 0

func _shoot(_target:Dictionary) -> void:
	pass

func _process(_delta:float):
	var tar:Dictionary = Main.get_target()
	if tar.valid == false:
		return
	_head.look_at(tar.position, Vector3.UP)
	_torso.rotation_degrees.y = _head.rotation_degrees.y

	_tick -= _delta
	if _tick <= 0:
		_tick = 0.25
		# _shoot(tar)
		_turret.immediate_fire(tar.position)
