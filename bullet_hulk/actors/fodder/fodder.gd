extends CharacterBody3D

var _hp:float = 10.0

var _tick:float = 2.0
var _refireTime:float = 0.5

func _fire() -> void:
	var prj:PrjColumn = Game.prj_column()
	var launch:PrjLaunchInfo = prj.get_launch_info()
	var t:Transform3D = self.global_transform
	launch.origin = t.origin + Vector3(0, 1, 0)
	launch.forward = -t.basis.z
	launch.speed = 6
	prj.launch_projectile()
	
	var t2:Transform3D = t
	t2.origin = Vector3()
	t2 = t2.rotated(t2.basis.y, deg_to_rad(22.5))
	t2.origin = t.origin
	prj = Game.prj_column()
	launch = prj.get_launch_info()
	launch.origin = t2.origin + Vector3(0, 1, 0)
	launch.forward = -t2.basis.z
	launch.speed = 6
	prj.launch_projectile()
	
	t2 = t
	t2.origin = Vector3()
	t2 = t2.rotated(t2.basis.y, deg_to_rad(-22.5))
	t2.origin = t.origin
	prj = Game.prj_column()
	launch = prj.get_launch_info()
	launch.origin = t2.origin + Vector3(0, 1, 0)
	launch.forward = -t2.basis.z
	launch.speed = 6
	prj.launch_projectile()

func _physics_process(_delta:float) -> void:
	var target:TargetInfo = Game.get_target()
	if target == null:
		return
	self.look_at(target.t.origin)
	
	_tick -= _delta
	if _tick <= 0.0:
		_tick = _refireTime
		_fire()

func hurt(atk:AttackInfo) -> int:
	if _hp > 0.0:
		_hp -= atk.damage
		if _hp <= 0.0:
			self.queue_free()
			return 1
		print("ow")
	else:
		print("already dead")
	return 1
