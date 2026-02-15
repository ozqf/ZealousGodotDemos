extends CharacterBody3D
class_name Mob

const MOB_PREFAB_FODDER:String = "fodder"
const MOB_FODDER_PRJ_STREAM:String = "fodder_prj_stream"
const MOB_PREFAB_BRUTE:String = "brute"

const ATK_INDEX_NONE:int = -1
const ATK_INDEX_BASIC:int = 0
const ATK_INDEX_COLUMN_SPREAD:int = 0
const ATK_INDEX_COLUMN_HORIZONTAL:int = 0

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
		mob.get_mob_settings().spawnPoint = t
		mob.start_mob()
	return mob

enum State
{
	Idle,
	Hunting
}

@export var mobPrefab:String = ""

var source:MobSpawner = null
var startNode:Node3D = null
var moveNode:Node3D = null # child of startNode we are moving to
var moveNodeIndex:int = 0 # index of the child node we are moving to

@onready var _launchNode:Node3D = $launch_node
@onready var _agent:NavigationAgent3D = $NavigationAgent3D
@onready var _muzzleFlash:ZqfTimedVisible = $launch_node/ZqfTimedVisible
@onready var _settings:MobSettings = $MobSettings
@onready var _thinkInfo:MobThinkInfo = $MobThinkInfo

var _state:State = State.Idle
var _hp:float = 100.0
var _tick:float = 2.0
var _tock:int = 0
var _refireTime:float = 1.2
var _hitscan:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()

var _atkIndex:int = 0

func _ready() -> void:
	assert(_thinkInfo != null)
	_agent.connect("velocity_computed", _velocity_computed)
	pass

func get_mob_settings() -> MobSettings:
	return _settings

func start_mob() -> void:
	if startNode != null:
		self.global_transform = startNode.global_transform
		if startNode.get_child_count() > 0:
			moveNode = startNode.get_child(moveNodeIndex)

	#self.global_transform = _settings.spawnPoint
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

func _fire_single() -> void:
	var prj:PrjLinear = Game.prj_column()
	var launch:PrjLaunchInfo = prj.get_launch_info()
	var t:Transform3D = _launchNode.global_transform
	launch.origin = t.origin # + Vector3(0, 1, 0)
	launch.forward = -t.basis.z
	launch.speed = 4
	launch.rollDegrees = 90.0
	prj.launch_projectile()

func _fire_fan() -> void:
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

func _try_attack_start(think:MobThinkInfo) -> int:
	var pendingIndex:int = ATK_INDEX_NONE
	match mobPrefab:
		MOB_PREFAB_BRUTE:
			pass
		_:
			if think.hasLoS:
				pendingIndex = ATK_INDEX_BASIC
	return pendingIndex

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

# returns true if still following a path
func _follow_path(delta:float) -> bool:
	if moveNode == null || startNode == null:
		return false
	var tarPos:Vector3 = moveNode.global_position
	if self.global_position.distance_squared_to(tarPos) < 1.0:
		moveNodeIndex += 1
		var loopPath:bool = false if source == null else source.loopPath
		if moveNodeIndex >= startNode.get_child_count():
			if !loopPath:
				return false
			moveNodeIndex = 0
		moveNode = startNode.get_child(moveNodeIndex)
	_walk_toward(delta, moveNode.global_position)
	return true

#endregion

#region updates

# returns true if hunting
func _refresh_think_info(think:MobThinkInfo) -> bool:
	var target:TargetInfo = Game.get_target()
	if target.age > 2:
		# target info is stale
		think.target = null
		return false
	think.target = target
	
	# check LOS from launch node not head
	self._launchNode.look_at(think.target.headT.origin)
	var hasLoS:bool = _has_los(_launchNode.global_position, think.target.headT.origin)
	
	return true


func _tick_fodder(_delta:float, think:MobThinkInfo) ->void:
	self.look_at_flat(think.target.headT.origin)
	
	var t:Transform3D = self.global_transform
	var distSqr:float = t.origin.distance_squared_to(think.target.t.origin)
	var minDistSqr:float = 2 * 2
	
	if distSqr > minDistSqr:
		# move to target
		_walk_toward(_delta, think.target.t.origin)
		return
	else:
		_agent.avoidance_enabled = false

func _tick_fodder_prj_stream(_delta:float, think:MobThinkInfo) -> void:
	self.look_at_flat(think.target.headT.origin)
	
	# check LOS from launch node not head
	self._launchNode.look_at(think.target.headT.origin)
	var hasLoS:bool = _has_los(_launchNode.global_position, think.target.headT.origin)
	
	_follow_path(_delta)

	_tick -= _delta
	if _tick <= 0.0 && hasLoS:
		_tick = _refireTime
		_tock += 1
		_muzzleFlash.start(0.1)
		var t:Transform3D = _launchNode.global_transform
		#var prj:PrjLinear = Game.prj_crescent()
		var prj:PrjLinear = Game.prj_sphere()
		var launch:PrjLaunchInfo = prj.get_launch_info()
		launch.origin = t.origin
		launch.forward = -t.basis.z
		launch.speed = 3
		prj.launch_projectile()

func _tick_brute(_delta:float, think:MobThinkInfo) ->void:
	self.look_at_flat(think.target.headT.origin)
	
	_tick -= _delta
	if _tick <= 0.0 && think.hasLoS:
		_tick = _refireTime
		_muzzleFlash.start(0.1)
		var category:int = Interactions.calc_attack_category(self.global_position, think.target.t.origin)
		match category:
			Interactions.ATK_CATEGORY_ABOVE_TARGET:
				_fire_fan()
			Interactions.ATK_CATEGORY_BELOW_TARGET:
				_fire_fan()
			_:
				var t:Transform3D = _launchNode.global_transform
				var origin:Vector3 = t.origin
				var forward:Vector3 = -t.basis.z
				forward.y = 0.0
				forward = forward.normalized()
				if _tock % 2 == 0:
					_fire_fan()
				else:
					var prj:PrjLinear = Game.prj_column()
					var launch:PrjLaunchInfo = prj.get_launch_info()
					if think.target.isCrouching:
						# drop projectile to floor
						origin.y = self.global_position.y + 0.2
					launch.origin = origin # + Vector3(0, 1, 0)
					launch.forward = forward
					launch.speed = 4
					launch.rollDegrees = 90.0
					prj.launch_projectile()
		_tock += 1

func _physics_process(_delta:float) -> void:
	if !_refresh_think_info(_thinkInfo):
		return
	
	match mobPrefab:
		MOB_FODDER_PRJ_STREAM:
			_tick_fodder_prj_stream(_delta, _thinkInfo)
		MOB_PREFAB_BRUTE:
			_tick_brute(_delta, _thinkInfo)
		MOB_PREFAB_FODDER, _:
			_tick_fodder(_delta, _thinkInfo)

#endregion

func hurt(atk:AttackInfo) -> int:
	if _hp > 0.0:
		_hp -= atk.damage
		if _hp <= 0.0:
			self.queue_free()
			return 1
		#print("ow")
	else:
		print("already dead")
	return 1
