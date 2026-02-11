extends CharacterBody3D
class_name Mob

const MOB_PREFAB_FODDER:String = "fodder"
const MOB_PREFAB_BRUTE:String = "brute"

enum State
{
	Idle,
	Hunting
}

@export var mobPrefab:String = ""

@onready var _launchNode:Node3D = $launch_node
@onready var _agent:NavigationAgent3D = $NavigationAgent3D

var _state:State = State.Idle
var _hp:float = 100.0
var _tick:float = 2.0
var _tock:int = 0
var _refireTime:float = 1.2
var _hitscan:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()

func _ready() -> void:
	pass

func spawn_mob() -> void:
	match mobPrefab:
		MOB_PREFAB_BRUTE:
			_hp = 100.0
			_refireTime = 0.5
			pass
			
		MOB_PREFAB_FODDER, _:
			_hp = 20
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
	if _tock % 2 == 0:
		_fire_spread()
	else:
		_fire_single()

func _fire_single() -> void:
	var prj:PrjColumn = Game.prj_column()
	var launch:PrjLaunchInfo = prj.get_launch_info()
	var t:Transform3D = _launchNode.global_transform
	launch.origin = t.origin # + Vector3(0, 1, 0)
	launch.forward = -t.basis.z
	launch.speed = 4
	launch.rollDegrees = 90.0
	prj.launch_projectile()

func _fire_spread() -> void:
	var t:Transform3D = _launchNode.global_transform
	var t2:Transform3D
	var numPrj:int = 5
	var arcDegrees:float = 135
	for i in range(0, numPrj):
		var yawDegrees:float = ZqfUtils.calc_fan_yaw(arcDegrees, i, numPrj)
		t2 = Transform3D.IDENTITY
		t2.basis = t.basis
		t2 = t2.rotated(t2.basis.y, deg_to_rad(yawDegrees))
		#t2.origin = t.origin
		var prj:PrjColumn = Game.prj_column()
		var launch:PrjLaunchInfo = prj.get_launch_info()
		launch.origin = t.origin# + Vector3(0, 1, 0)
		launch.forward =  -t2.basis.z
		launch.speed = 4
		prj.launch_projectile()

func look_at_flat(pos:Vector3) -> void:
	pos.y = self.global_position.y
	self.look_at(pos)

func _physics_process(_delta:float) -> void:
	match _state:
		pass
	var target:TargetInfo = Game.get_target()
	if target.age > 2:
		# target info is stale
		return
	self.look_at_flat(target.headT.origin)
	
	#var t:Transform3D = self.global_transform
	#var distSqr:float = t.origin.distance_squared_to(target.t.origin)
	#var minDistSqr:float = 1.5 * 1.5
	
	# check LOS from launch node not head
	self._launchNode.look_at(target.headT.origin)
	var hasLoS:bool = _has_los(_launchNode.global_position, target.headT.origin)
	
	_agent.target_position = target.t.origin
	
	_tick -= _delta
	if _tick <= 0.0 && hasLoS:
		_tick = _refireTime
		_fire()
		_tock += 1

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
