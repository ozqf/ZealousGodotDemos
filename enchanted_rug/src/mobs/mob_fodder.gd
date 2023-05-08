extends Node

var _projectile_t = preload("res://prefabs/projectiles/prj_ball_large.tscn")

onready var _head:Spatial = $head
onready var _torso:Spatial = $torso
onready var _turret = $head/turret

export var fodderType:int = 1
export var inactive:bool = false

var _tick:float = 0
var _refireTime:float = 3 # 0.25
var _prjInfo:PrjLaunchInfo = null

func _ready() -> void:
	_turret.projectileType = 6
	_prjInfo = Main.new_prj_info()

# returns true if firing was successful
func _shoot(_launchInfo:PrjLaunchInfo, _targetOffset:Vector3) -> bool:
	var originalTar:Vector3 = _launchInfo.target
	_launchInfo.target += _targetOffset
	_prjInfo.origin = _turret.global_transform.origin
	
	if !ZqfUtils.los_check(_turret, _turret.global_transform.origin, _prjInfo.target, 1):
		# restore
		_launchInfo.target = originalTar
		return false
	_prjInfo.forward = (_prjInfo.origin - _prjInfo.target).normalized()
	_prjInfo.forward = Vector3.UP
	_turret.immediate_fire(_prjInfo)
	# restore
	_launchInfo.target = originalTar
	return true

func _shoot_test() -> void:
	print("Shoot missile test")
	_prjInfo.target = _turret.global_transform.origin + Vector3.UP
	_shoot(_prjInfo, Vector3.ZERO)

func _tick_as_turret(_delta:float) -> void:
	var tar:Dictionary = Main.get_target()
	if tar.valid == false:
		return
	var tarSpeed:float = (tar.velocity * 1.0).length()
	var aimPos:Vector3 = tar.position + (tar.velocity * 1.0)
	_head.look_at(aimPos, Vector3.UP)
	_torso.rotation_degrees.y = _head.rotation_degrees.y
	_tick -= _delta
	if _tick <= 0:
		_prjInfo.target = aimPos
		
		if !ZqfUtils.los_check(_turret, _turret.global_transform.origin, aimPos, 1):
			return
		if fodderType == 1:
			pass
		else:
			
#			_tick = _refireTime
			var count:int = 0
			_shoot_test()
			count += 1
#			if _shoot(_prjInfo, Vector3.ZERO):
#				count += 1
#			for _i in range(0, 1):
#				var offset:Vector3 = Vector3(
#					rand_range(-tarSpeed, tarSpeed),
#					rand_range(-tarSpeed, tarSpeed),
#					rand_range(-tarSpeed, tarSpeed))
#				if _shoot(_prjInfo, offset):
#					count += 1
			
			# reset firing time if something launched
			if count > 0:
				_tick = _refireTime
			#_turret.immediate_fire(_prjInfo)

func _process(_delta:float):
	if inactive:
		return
	_tick_as_turret(_delta)
	if Input.is_action_just_pressed("debug_1"):
		_shoot_test()
