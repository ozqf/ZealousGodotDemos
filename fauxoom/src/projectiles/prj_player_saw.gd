extends RigidBody
class_name SawBlade

enum State { Idle, Thrown, Stuck, Dropped, Recall }

const GUIDED_SPEED:float = 25.0
const UNGUIDED_SPEED:float = 50.0

const REV_DOWN_TIME:float = 8.0

onready var _display:Spatial = $display
onready var _sparks1:CPUParticles = $display/sparks_1
onready var _sparks2:CPUParticles = $display/sparks_2

var _state = State.Idle
var _currentSpeed:float = 25
var _emptyArray = []
var _guided:bool = false
var _hitInfo:HitInfo = null
var revs:float = 0
var _rotDegrees:float = 0

func _ready() -> void:
	visible = false
	_hitInfo = Game.new_hit_info()
	_hitInfo.damage = 15
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_SAW_PROJECTILE
	_hitInfo.comboType = Interactions.COMBO_CLASS_STAKE
	_sparks1.emitting = false
	_sparks2.emitting = false

func launch(originT:Transform, launchRevs:float) -> void:
	disable_body()
	visible = true
	revs = launchRevs
	global_transform = originT
	_state = State.Thrown
	# print("Saw - launch!")

func off() -> void:
	disable_body()
	_state = State.Idle
	visible = false
	_sparks1.emitting = false
	_sparks2.emitting = false

func set_stuck() -> void:
	_state = State.Stuck
	_sparks1.emitting = true
	_sparks2.emitting = true

func disable_body() -> void:
	mode = RigidBody.MODE_KINEMATIC

func set_dropped() -> void:
	_state = State.Dropped
	mode = RigidBody.MODE_RIGID
	_sparks1.emitting = false
	_sparks2.emitting = false

func _apply_dropped_push(normal:Vector3) -> void:
	var pushPos:Vector3 = Vector3()
	pushPos.x = rand_range(-0.3, 0.3)
	pushPos.y = rand_range(-0.3, 0.3)
	pushPos.z = rand_range(-0.3, 0.3)
	apply_impulse(pushPos, normal * 5)

func start_recall() -> void:
	_state = State.Recall
	_sparks1.emitting = false
	_sparks2.emitting = false
	
func _move_as_ray(_delta:float, speed:float) -> void:
	var t:Transform = global_transform
	var space = get_world().direct_space_state
	var origin:Vector3 = t.origin
	var dir:Vector3 = -t.basis.z
	# move ray origin back slightly or tunneling can occur.
	origin -= (dir * 0.1)
	var velocity:Vector3 = (dir * speed) * _delta
	var dest:Vector3 = origin + velocity

	var mask:int = -1
	# interactives are 'areas' so also need to hit these
	var result = space.intersect_ray(origin, dest, _emptyArray, mask, true, true)
	var move:bool = true
	if result:
		_hitInfo.direction = dir
		var body:CollisionObject = result.collider

		var _inflicted:int = Interactions.hitscan_hit(_hitInfo, result)
		if _inflicted >= 0:
			print("Sawblade Hit entity - revs: " + str(revs) + " stuntime: " + str(_hitInfo.stunOverrideTime))
			# start_recall()
			global_transform.origin = result.position
			if revs > 10:
				set_stuck()
			else:
				print("Sawblade drop - no revs for entity hit")
				set_dropped()
				_apply_dropped_push(result.normal)
				# apply_central_impulse(result.normal * 5)
			global_transform.origin = result.position
			return

		# check vs interactor
		elif (body.collision_layer & Interactions.INTERACTIVE) != 0:
			print("Hit interactive body")
			# Interactions.use_collider(body)
			set_stuck()
			move = false
			# print("Saw - stuck!")
			global_transform.origin = result.position
			return
		
		# saw blade is only projectile stopped by barriers
		elif (body.collision_layer & Interactions.PLAYER_BARRIER) != 0:
			set_dropped()
			_apply_dropped_push(result.normal)
			global_transform.origin = result.position
			return

		# check vs world
		# only stick into world if unguided
		elif (body.collision_layer & 1) != 0:
			if _guided == true:
				return
			print("Hit world")
			if revs > 0:
				set_stuck()
			else:
				set_dropped()
				_apply_dropped_push(result.normal)
			move = false
			# print("Saw - stuck!")
			global_transform.origin = result.position
			return
	if move:
		global_transform.origin = dest

func turn_toward_point(pos:Vector3) -> void:
	var towardPoint:Transform = global_transform.looking_at(pos, Vector3.UP)
	var result:Transform = transform.interpolate_with(towardPoint, 0.8)
	set_transform(result)

func _state_allows_recall() -> bool:
	return (_state == State.Thrown || _state == State.Stuck || _state == State.Dropped)

func user_switched_weapon() -> void:
	if _state == State.Dropped:
		start_recall()

# returns 1 if parent can reset to idle state
func read_input(_weaponInput:WeaponInput) -> int:
	var result:int = 0
	if _state == State.Thrown:
		_guided = _weaponInput.secondaryOn
	if (_state_allows_recall()) && (_weaponInput.primaryOn && !_weaponInput.primaryOnPrev):
		_state = State.Idle
		# print("Saw - recall!")
		start_recall()
		result = 0
	if _state == State.Idle:
		result = 1
	return result

func spin_display(_delta:float) -> void:
	var rate:float = (360 * 8) * (revs / 100)
	_rotDegrees -= rate * _delta
	_display.rotation_degrees = Vector3(_rotDegrees, 0, 0)

func _calc_stun_time() -> float:
	var timeFromRevs:float = REV_DOWN_TIME * (revs / 100.0)
	if  timeFromRevs < 1:
		timeFromRevs = 1
	return timeFromRevs

func _physics_process(_delta):
	# if we have no player to belong to just switch off
	var targetDict:Dictionary = AI.get_player_target()
	if targetDict.id == 0:
		off()
		return
	
	_hitInfo.stunOverrideTime = _calc_stun_time()
	_hitInfo.stunOverrideDamage = int(revs)
	# tick
	if _state == State.Thrown:
		spin_display(_delta)
		if _guided:
			turn_toward_point(targetDict.aimPos)
			_move_as_ray(_delta, GUIDED_SPEED)
		else:
			_move_as_ray(_delta, UNGUIDED_SPEED)
	elif _state == State.Stuck:
		if revs > 0:
			revs -= (100.0 / REV_DOWN_TIME) * _delta
			if revs < 0:
				revs = 0
			# this doesn't seem to work... do particle emitters
			# not like their amount value changing?
			# var particleCount:int = int(64.0 * (revs / 100.0))
			# if particleCount <= 0:
			# 	particleCount = 1
			# print("Particle count " + str(particleCount))
			# _sparks1.amount = particleCount
			# _sparks2.amount = particleCount
			_sparks1.amount = 16
			_sparks2.amount = 16
		else:
			print("Sawblade drop - ran out of revs")
			set_dropped()
		spin_display(_delta)
	elif _state == State.Recall:
#		print("...Recall tick...")
		var pos:Vector3 = global_transform.origin
		var tar:Vector3 = targetDict.position
		var dist:float = pos.distance_to(tar)
		if dist <= 2.0:
			off()
			return
		global_transform.origin = pos.linear_interpolate(tar, 0.25)
	else:
		pass
