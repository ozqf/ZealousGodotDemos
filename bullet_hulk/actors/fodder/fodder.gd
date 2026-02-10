extends CharacterBody3D

enum State
{
	Idle,
	Hunting
}

@onready var _launchNode:Node3D = $launch_node
@onready var _agent:NavigationAgent3D = $NavigationAgent3D

var _state:State = State.Idle
var _hp:float = 80.0
var _tick:float = 2.0
var _refireTime:float = 1.2
var _hitscan:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()

func _ready() -> void:
	pass

func _has_los(a:Vector3, b:Vector3) -> bool:
	_hitscan.collision_mask = Interactions.get_los_mask()
	_hitscan.collide_with_bodies = true
	_hitscan.collide_with_areas = false
	_hitscan.from = a
	_hitscan.to = b
	var result:Dictionary = self.get_world_3d().direct_space_state.intersect_ray(_hitscan)
	return result.is_empty()

func _fire() -> void:
	var prj:PrjColumn = Game.prj_column()
	var launch:PrjLaunchInfo = prj.get_launch_info()
	var t:Transform3D = self.global_transform
	launch.origin = t.origin + Vector3(0, 1, 0)
	launch.forward = -t.basis.z
	launch.speed = 4
	prj.launch_projectile()
	
	var t2:Transform3D = t
	t2.origin = Vector3()
	t2 = t2.rotated(t2.basis.y, deg_to_rad(22.5))
	t2.origin = t.origin
	prj = Game.prj_column()
	launch = prj.get_launch_info()
	launch.origin = t2.origin + Vector3(0, 1, 0)
	launch.forward = -t2.basis.z
	launch.speed = 4
	prj.launch_projectile()
	
	t2 = t
	t2.origin = Vector3()
	t2 = t2.rotated(t2.basis.y, deg_to_rad(-22.5))
	t2.origin = t.origin
	prj = Game.prj_column()
	launch = prj.get_launch_info()
	launch.origin = t2.origin + Vector3(0, 1, 0)
	launch.forward = -t2.basis.z
	launch.speed = 4
	prj.launch_projectile()

func _physics_process(_delta:float) -> void:
	match _state:
		pass
	var target:TargetInfo = Game.get_target()
	if target.age > 2:
		# target info is stale
		return
	self.look_at(target.t.origin)
	
	var t:Transform3D = self.global_transform
	var distSqr:float = t.origin.distance_squared_to(target.t.origin)
	var minDistSqr:float = 1.5 * 1.5
	
	var hasLoS:bool = _has_los(_launchNode.global_position, target.headT.origin)
	
	_agent.target_position = target.t.origin
	
	_tick -= _delta
	if _tick <= 0.0 && hasLoS:
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
