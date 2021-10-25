extends Spatial
class_name AITicker

const STATE_MOVE:int = 0
const STATE_WINDUP:int = 1
const STATE_ATTACK:int = 2
const STATE_WINDDOWN:int = 3
const STATE_REPEAT:int = 4

const MOVEMODE_CHARGE:int = 0
const MOVEMODE_EVADE:int = 1
# const MOVEMODE_RETREAT:int = 2

var _moveMode:int = 0

# state info read from attack when started
# var _maxCycles:int = 1
# var _faceTargetDuringWindup:bool = true

var _stats:MobStats

var _state:int = -1
var _tick:float = 0.0
var _cycles:int = 0
var isSniper:bool = false

var moveAndAttack:bool = true

var _attackIndex:int = -1
var _attackMode:int = 0
var _revengeAttack:bool = false

var lastTarPos:Vector3 = Vector3()

var _mob

func custom_init(mob, stats:MobStats) -> void:
	_mob = mob
	_stats = stats
	custom_init_b()

func custom_init_b() -> void:
	pass

func get_attack() -> MobAttack:
	return _mob.attacks[_attackIndex]

func start_hunt() -> void:
	change_state(0)
	if _revengeAttack:
		# end move think immediately and try to attack
		# next tick
		_tick = 0
		_revengeAttack = false

func stop_hunt() -> void:
	pass

func stun_ended() -> void:
	_revengeAttack = true

func change_state(newState:int) -> void:
	if newState == _state:
		return
	var oldState:int = _state
	_state = newState
	
	if custom_change_state(_state, oldState):
		return
	
	if _state == STATE_MOVE:
		_mob.sprite.play_animation("walk")
		_tick = _stats.moveTime
	elif _state == STATE_WINDUP:
		_mob.sprite.play_animation("aim")
		_tick = get_attack().windUpTime
		_mob.head.look_at(lastTarPos, Vector3.UP)
		var atk = _mob.attacks[_attackIndex]
		if _mob.aimLaser != null && atk.showAimLaser:
			_mob.aimLaser.on(_tick)
		if _mob.omniCharge != null && atk.showOmniCharge:
			_mob.omniCharge.on(_tick)
	elif _state == STATE_ATTACK:
		_mob.sprite.play_animation("shoot")
		_mob.attacks[_attackIndex].fire(lastTarPos) 
		_tick = get_attack().attackAnimTime
	elif _state == STATE_WINDDOWN:
		_mob.sprite.play_animation("aim")
		_tick = get_attack().windDownTime

# return true if state change was handled
# false to allow base function to handle it instead
func custom_change_state(_newState:int, _oldState:int) -> bool:
	return false

func _start_attack(_delta:float, _tickInfo:AITickInfo) -> void:
	_attackIndex = _select_attack(_tickInfo)
	if _attackIndex < 0:
		return
	# maxCycles = _mob.attacks[_attackIndex].attackCount
	_cycles = 0
	lastTarPos = _tickInfo.targetPos
	_mob.face_target_flat(lastTarPos)
	change_state(STATE_WINDUP)

func _select_attack(_tickInfo:AITickInfo) -> int:
	var dist:float = _tickInfo.trueDistance
	var numAttacks:int = _mob.attacks.size()
	for _i in range (0, numAttacks):
		var att:MobAttack = _mob.attacks[_i]
		if dist < att.minUseRange:
			continue
		elif dist > att.maxUseRange:
			continue
		return _i
	return -1

func set_rotation_to_movement() -> void:
	_mob.sprite.yawDegrees = rad2deg(_mob.motor.moveYaw)

func set_rotation_to_target(pos:Vector3) -> void:
	var yawDegrees:float = ZqfUtils.yaw_between(_mob.global_transform.origin, pos)
	yawDegrees = rad2deg(yawDegrees)
	_mob.sprite.yawDegrees = yawDegrees

func _attack_move(_delta:float) -> void:
	if moveAndAttack:
		# _mob.motor.move_hunt(_delta)
		_mob.motor.move_evade(_delta)
	else:
		_mob.motor.move_idle(_delta)

func validate_move_target(_delta:float, _tickInfo:AITickInfo) -> void:
	var isNotInjured:bool = _tickInfo.healthPercentage >= 50
	var agent = _mob.motor.get_agent()

	if isNotInjured:
		if _mob.roleId == 1:
			# find a sniping position
			if agent.tacticNode == null || !agent.tacticNode.sniperSpot:
				if AI.find_sniper_position(agent):
					_mob.motor.set_move_target(agent.target)
					print("Sniper move target is " + str(agent.target) + " waypoint " + str(agent.tacticNode.index))
					return
				else:
					# fall back to just being a charger
					print("Mob can't find a sniper position!")
					_mob.motor.set_move_target(_tickInfo.targetPos)
		else:
			var distMode:int = 0
			if _tickInfo.canSeeTarget:
				_mob.motor.set_move_target(_tickInfo.targetPos)
				# we can see player so player can see us.
				# switch to random evasion
				pass
				# if _tickInfo.moveThinkTick <= 0:
				# 	_tickInfo.moveThinkTick = 0.25
				# 	var v:Vector3 = _mob.motor.pick_evade_point(_tickInfo.verbose)
				# 	_mob.motor.set_move_target(v)
			else:
				# can't see target, move directly toward them
				_mob.motor.set_move_target(_tickInfo.targetPos)
		pass
	else:
		# "Runaway. Runaway. Run Children. Run for your life!
		# Runaway. Runaway. Run children. Here it comes. I said run. Alright"
		if agent.tacticNode == null || agent.tacticNode.canSeePlayer:
			if AI.find_flee_position(_mob.motor.get_agent()):
				_mob.motor.set_move_target(_mob.motor.get_agent().target)
	pass

func custom_tick_state(_delta:float, _tickInfo:AITickInfo) -> void:
	_tickInfo.moveThinkTick -= _delta
	validate_move_target(_delta, _tickInfo)
	if _state == STATE_MOVE:
		if isSniper:
			_start_attack(_delta, _tickInfo)
			return
		# if _tickInfo.healthPercentage > 50:
		# 	_mob.motor.set_move_target(_tickInfo.targetPos)
		# 	_mob.motor.set_move_target_forward(_tickInfo.targetForward)
		# else:
		# 	# pick a flee point
		# 	if AI.find_flee_position(_mob.motor.get_agent()):
		# 		_mob.motor.set_move_target(_mob.motor.get_agent().target)
		# 	pass
		if _tickInfo.trueDistance > 2:
			_mob.motor.move_hunt(_delta)
			set_rotation_to_movement()
		if _tick <= 0 && _tickInfo.trueDistance <= 25 && _tickInfo.canSeeTarget:
			# print("AI ticker - attack")
			_start_attack(_delta, _tickInfo)
			set_rotation_to_target(_tickInfo.targetPos)
	
	elif _state == STATE_WINDUP:
		_attack_move(_delta)
		if get_attack().faceTargetDuringWindup:
			_mob.head.look_at(_tickInfo.targetPos, Vector3.UP)
			lastTarPos = _tickInfo.targetPos
			_mob.face_target_flat(lastTarPos)
		if _tick <= 0:
			change_state(STATE_ATTACK)
	elif _state == STATE_ATTACK:
		_attack_move(_delta)
		# _mob.face_target_flat(_tickInfo.targetPos)
		if _tick <= 0:
			_cycles += 1
			if _cycles < get_attack().attackCount:
				change_state(STATE_WINDUP)
				_tick = get_attack().repeatTime
			else:
				change_state(STATE_WINDDOWN)
	elif _state == STATE_WINDDOWN:
		_attack_move(_delta)
		if _tick <= 0:
			change_state(STATE_MOVE)
	else:
		change_state(STATE_MOVE)

func custom_tick(_delta:float, _tickInfo:AITickInfo) -> void:
	_tick -= _delta
	custom_tick_state(_delta, _tickInfo)
	
