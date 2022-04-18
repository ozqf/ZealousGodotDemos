extends Node

var _projectile_t = preload("res://prefabs/projectiles/prj_ball_large.tscn")

onready var _head:Spatial = $head
onready var _torso:Spatial = $torso
onready var _turret = $head/turret

export var fodderType:int = 0

var _tick:float = 0
var _refireTime:float = 2 # 0.25
var _prjInfo:PrjLaunchInfo = null

func _ready() -> void:
	_turret.projectileType = 5
	_prjInfo = Main.new_prj_info()

func _shoot(_target:Dictionary) -> void:
	pass

func _process(_delta:float):
	var tar:Dictionary = Main.get_target()
	if tar.valid == false:
		return
	var aimPos:Vector3 = tar.position + (tar.velocity * 1.0)
	_head.look_at(aimPos, Vector3.UP)
	_torso.rotation_degrees.y = _head.rotation_degrees.y

	_tick -= _delta
	if _tick <= 0:
		if !ZqfUtils.los_check(_turret, _turret.global_transform.origin, aimPos, 1):
			return
		if fodderType == 1:
			pass
		else:
			_tick = _refireTime
			# _shoot(tar)
			_turret.immediate_fire(aimPos)
