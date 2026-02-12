extends CharacterBody3D
class_name Mob

const MOB_PREFAB_FODDER:String = "fodder"
const MOB_FODDER_PRJ_STREAM:String = "fodder_prj_stream"
const MOB_PREFAB_BRUTE:String = "brute"

static var _fodderType:PackedScene = preload("res://actors/mobs/fodder.tscn")
static var _bruteType:PackedScene = preload("res://actors/mobs/brute.tscn")

static func _get_prefab(mobPrefabName:String) -> PackedScene:
	match mobPrefabName:
		MOB_PREFAB_BRUTE:
			return _bruteType
		_:
			return _fodderType

static func spawn_new_mob(mobPrefabName:String, t:Transform3D, newParent:Node3D, spawnImmediately:bool = true) -> Mob:
	assert(newParent != null)
	var src:PackedScene = _get_prefab(mobPrefabName)
	assert(src != null)
	var mob:Mob = src.instantiate() as Mob
	assert(mob != null)
	mob.mobPrefab = mobPrefabName
	newParent.add_child(mob)
	if spawnImmediately:
		mob.start_mob()
	return mob

enum State
{
	Idle,
	Hunting
}

@export var mobPrefab:String = ""

@onready var _launchNode:Node3D = $launch_node
@onready var _agent:NavigationAgent3D = $NavigationAgent3D
@onready var _muzzleFlash:ZqfTimedVisible = $launch_node/ZqfTimedVisible

var _state:State = State.Idle
var _hp:float = 100.0
var _tick:float = 2.0
var _tock:int = 0
var _refireTime:float = 1.2
var _hitscan:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()

func _ready() -> void:
	_agent.connect("velocity_computed", _velocity_computed)
	pass

func start_mob() -> void:
	match mobPrefab:
		MOB_PREFAB_BRUTE:
			_hp = 100.0
			_refireTime = 0.5
			pass
		MOB_FODDER_PRJ_STREAM:
			_hp = 10
			_refireTime = 0.2
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
	var prj:PrjLinear = Game.prj_column()
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
		var prj:PrjLinear = Game.prj_column()
		var launch:PrjLaunchInfo = prj.get_launch_info()
		launch.origin = t.origin# + Vector3(0, 1, 0)
		launch.forward =  -t2.basis.z
		launch.speed = 4
		prj.launch_projectile()

func look_at_flat(pos:Vector3) -> void:
	pos.y = self.global_position.y
	self.look_at(pos)

#region movement

func _walk_toward(delta:float, pos:Vector3) -> bool:
	_agent.target_position = pos
	var isReachable:bool = _agent.is_target_reachable()
	if !isReachable:# && abortIfTargetNotReachable:
		_agent.avoidance_enabled = false
		return false
	_agent.avoidance_enabled = true
	var nextOnMesh:Vector3 = _agent.get_next_path_position()
	var navMeshCellHeight:float = 0.25
	var nextOnGround:Vector3 = nextOnMesh + Vector3(0, -navMeshCellHeight, 0)
	var t:Transform3D = self.global_transform
	var toward:Vector3 = t.origin.direction_to(nextOnGround)
	var v:Vector3 = self.velocity
	v.x += (toward.x * 5) * delta
	v.z += (toward.z * 5) * delta
	v = v.limit_length(4)
	#v += (toward * 40) * delta
	_agent.set_velocity(v)
	return true

func _velocity_computed(safeVelocity:Vector3) -> void:
	self.velocity = safeVelocity
	if safeVelocity.is_zero_approx():
		print("zero safe velocity!")
	self.move_and_slide()

#endregion

#region updates

func _tick_fodder(_delta:float, target:TargetInfo) ->void:
	self.look_at_flat(target.headT.origin)
	
	var t:Transform3D = self.global_transform
	var distSqr:float = t.origin.distance_squared_to(target.t.origin)
	var minDistSqr:float = 2 * 2
	
	if distSqr > minDistSqr:
		# move to target
		_walk_toward(_delta, target.t.origin)
		return
	else:
		_agent.avoidance_enabled = false

func _tick_fodder_prj_stream(_delta:float, target:TargetInfo) -> void:
	self.look_at_flat(target.headT.origin)
	
	# check LOS from launch node not head
	self._launchNode.look_at(target.headT.origin)
	var hasLoS:bool = _has_los(_launchNode.global_position, target.headT.origin)
	
	_tick -= _delta
	if _tick <= 0.0 && hasLoS:
		_tick = _refireTime
		_tock += 1
		_muzzleFlash.start(0.1)
		var t:Transform3D = _launchNode.global_transform
		var prj:PrjLinear = Game.prj_crescent()
		var launch:PrjLaunchInfo = prj.get_launch_info()
		launch.origin = t.origin
		launch.forward = -t.basis.z
		launch.speed = 3
		prj.launch_projectile()

func _tick_brute(_delta:float, target:TargetInfo) ->void:
	self.look_at_flat(target.headT.origin)
	
	# check LOS from launch node not head
	self._launchNode.look_at(target.headT.origin)
	var hasLoS:bool = _has_los(_launchNode.global_position, target.headT.origin)
	
	
	_tick -= _delta
	if _tick <= 0.0 && hasLoS:
		_tick = _refireTime
		_muzzleFlash.start(0.1)
		_fire()
		_tock += 1

func _physics_process(_delta:float) -> void:
	var target:TargetInfo = Game.get_target()
	if target.age > 2:
		# target info is stale
		return
	

	match mobPrefab:
		MOB_FODDER_PRJ_STREAM:
			_tick_fodder_prj_stream(_delta, target)
		MOB_PREFAB_BRUTE:
			_tick_brute(_delta, target)
		MOB_PREFAB_FODDER, _:
			_tick_fodder(_delta, target)

#endregion

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
