extends CharacterBody3D
class_name Mob

const MOB_PREFAB_FODDER:String = "fodder"
const MOB_FODDER_PRJ_STREAM:String = "fodder_prj_stream"
const MOB_PREFAB_BRUTE:String = "brute"

const ATK_INDEX_NONE:int = -1
const ATK_INDEX_BASIC:int = 0
const ATK_INDEX_COLUMN_SPREAD:int = 1
const ATK_INDEX_COLUMN_HORIZONTAL:int = 2
const ATK_INDEX_COLUMN_SWITCH:int = 3

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
	Hunting,
	Dead
}

@export var mobPrefab:String = ""

var source:MobSpawner = null
var startNode:Node3D = null
var moveNode:Node3D = null # child of startNode we are moving to
var moveNodeIndex:int = 0 # index of the child node we are moving to

@onready var _launchNode:Node3D = $launch_node
@onready var _agent:NavigationAgent3D = $NavigationAgent3D
@onready var _settings:MobSettings = $MobSettings
@onready var _thinkInfo:MobThinkInfo = $MobThinkInfo
@onready var _model:MobModel = $Model

var _state:State = State.Idle
var _hp:float = 100.0
var _tick:float = 0.0
var _tock:int = 0
var _hitscan:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()

var _atkIndex:int = ATK_INDEX_NONE
var _atkModelIndex:int = 0
var _atkWindUp:float = 0.25
var _atkRepeat:float = 0.2
var _atkWindDown:float = 0.25
var _atkSerial:int = 0

func _ready() -> void:
	assert(_thinkInfo != null)
	_agent.connect("velocity_computed", _velocity_computed)
	pass

func mob_change_state(newState:State) -> void:
	if newState == State.Dead && _state != State.Dead:
		_state = State.Dead
		if _model != null:
			_model.reparent(Game.get_actors_root())
			_model.add_to_group("temp")
			_model.die()
			_model = null
		self.queue_free()
		return
	_state = newState

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
			_atkRepeat = 0.5
			pass
		MOB_FODDER_PRJ_STREAM:
			_hp = 30
			_atkRepeat = 0.2
			pass
		MOB_PREFAB_FODDER, _:
			_hp = 20
			pass
	_model.set_mob_prefab(mobPrefab)

func _has_los(a:Vector3, b:Vector3) -> bool:
	_hitscan.collision_mask = Interactions.get_los_mask()
	_hitscan.collide_with_bodies = true
	_hitscan.collide_with_areas = false
	_hitscan.from = a
	_hitscan.to = b
	var result:Dictionary = self.get_world_3d().direct_space_state.intersect_ray(_hitscan)
	return result.is_empty()

#region attacking
func _fire_single() -> void:
	var prj:PrjLinear = Game.prj_column()
	var launch:PrjLaunchInfo = prj.get_launch_info()
	var t:Transform3D = _launchNode.global_transform
	launch.origin = t.origin # + Vector3(0, 1, 0)
	launch.forward = -t.basis.z
	launch.speed = 4
	launch.rollDegrees = 90.0
	prj.launch_projectile()

func _fire_fan(numPrj:int) -> void:
	var t:Transform3D = _launchNode.global_transform
	var t2:Transform3D
	var arcDegrees:float = 90
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

func _try_attack_start(think:MobThinkInfo) -> bool:
	var pendingIndex:int = ATK_INDEX_NONE
	var pendingModelIndex:int = 0
	var pendingTocks:int = 1
	var category:int = Interactions.calc_attack_category(self.global_position, think.target.t.origin)
	match mobPrefab:
		MOB_PREFAB_BRUTE:
			_atkModelIndex = 0
			pendingTocks = 3
			match category:
				Interactions.ATK_CATEGORY_ABOVE_TARGET:
					pendingIndex = ATK_INDEX_COLUMN_SPREAD
				Interactions.ATK_CATEGORY_BELOW_TARGET:
					pendingIndex = ATK_INDEX_COLUMN_SPREAD
				_:
					pendingIndex = ATK_INDEX_COLUMN_SWITCH
					pendingTocks = 10
					_model.set_weapon_rotation(_atkModelIndex, 0)
					#if _atkSerial % 2 == 0:
					#	pendingIndex = ATK_INDEX_COLUMN_SPREAD
					#else:
					#	pendingIndex = ATK_INDEX_COLUMN_HORIZONTAL
					#	pendingModelIndex = 1
			_atkWindUp = 0.25
			_atkRepeat = 1.2
			_atkWindDown = 0.25
		_:
			if !think.hasLoS:
				return ATK_INDEX_NONE
			pendingIndex = ATK_INDEX_BASIC
			pendingTocks = 5
			_atkModelIndex = 0
			_atkWindUp = 0.25
			_atkRepeat = 0.2
			_atkWindDown = 0.25
	if pendingIndex != ATK_INDEX_NONE:
		_atkIndex = pendingIndex
		_atkModelIndex = pendingModelIndex
		_tock = pendingTocks
		_atkSerial += 1
		return true
	return false

# return true if attack should end
func _check_end_attack(think:MobThinkInfo) -> bool:
	match _atkIndex:
		_:
			if _tock <= 0:
				return true
			return !think.hasLoS

func _check_attack(think:MobThinkInfo) -> void:
	if _atkIndex == ATK_INDEX_NONE:
		_try_attack_start(think)
		return
	if _check_end_attack(think):
		_atkIndex = ATK_INDEX_NONE
	return

func _tock_generic(_delta:float, _think:MobThinkInfo) -> void:
	match _atkIndex:
		ATK_INDEX_COLUMN_SPREAD:
			_model.play_fire()
			_model.muzzle_flash(_atkModelIndex)
			_fire_fan(7)
		ATK_INDEX_COLUMN_HORIZONTAL:
			_model.play_fire()
			_model.muzzle_flash(_atkModelIndex)
			_fire_single()
		ATK_INDEX_COLUMN_SWITCH:
			_model.play_fire()
			_model.muzzle_flash(_atkModelIndex)
			if _tock % 2 == 0:
				_fire_fan(7)
				_model.set_weapon_rotation(_atkModelIndex, 90)
			else:
				# set rotation to vertical for next shot
				_model.set_weapon_rotation(_atkModelIndex, 0)

				var t:Transform3D = _launchNode.global_transform
				var o:Vector3 = t.origin
				if _think.target.isCrouching:
					# drop projectile to floor
					o.y = self.global_position.y + 0.2
				var f:Vector3 = -t.basis.z
				f.y = 0
				f = f.normalized()

				var prj:PrjLinear = Game.prj_column()
				var launch:PrjLaunchInfo = prj.get_launch_info()
				launch.origin = o
				launch.forward = f
				launch.speed = 5
				launch.rollDegrees = 90.0
				prj.launch_projectile()
		_:
			_model.play_fire()
			_model.muzzle_flash(_atkModelIndex)
			var t:Transform3D = _launchNode.global_transform
			#var prj:PrjLinear = Game.prj_crescent()
			var prj:PrjLinear = Game.prj_sphere()
			var launch:PrjLaunchInfo = prj.get_launch_info()
			launch.origin = t.origin
			launch.forward = -t.basis.z
			launch.speed = 5
			prj.launch_projectile()
	_tick = _atkRepeat
	_tock -= 1

#endregion

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
	if target.ticksSinceRefresh > 2:
		# target info is stale
		think.target = null
		return false
	think.target = target
	
	# check LOS from launch node not head
	self._launchNode.look_at(think.target.headT.origin)
	# TODO - to select a launch node we need to know the atk index and source on the model,
	# but how to know that before we select an attack.
	think.hasLoS = _has_los(_launchNode.global_position, think.target.headT.origin)
	
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

func _tick_generic(_delta:float, think:MobThinkInfo) -> void:
	if _model == null:
		return
	self.look_at_flat(think.target.headT.origin)
	_follow_path(_delta)
	
	_check_attack(think)
	if _atkIndex == ATK_INDEX_NONE:
		_model.end_aim_weapon()
		return
	_model.aim_weapon(_atkModelIndex, _atkWindUp)

	_tick -= _delta
	if _tick <= 0.0 && _model.is_aiming(_atkModelIndex):
		_tock_generic(_delta, think)

func _physics_process(_delta:float) -> void:
	if !_refresh_think_info(_thinkInfo):
		return
	match mobPrefab:
		MOB_PREFAB_FODDER:
			_tick_fodder(_delta, _thinkInfo)
		MOB_FODDER_PRJ_STREAM, _:
			_tick_generic(_delta, _thinkInfo)

#endregion

func hurt(atk:AttackInfo) -> int:
	if _state == State.Dead:
		return Interactions.HIT_IGNORE
	if atk.damage <= 0:
		return Interactions.HIT_IGNORE
	if atk.damage == 0:
		return Interactions.HIT_RESPONSE_WHIFF
	if _hp > 0.0:
		_hp -= atk.damage
		_model.hit_flinch(0.2)
		if _hp <= 0.0:
			mob_change_state(State.Dead)
			return 1
	return 1
