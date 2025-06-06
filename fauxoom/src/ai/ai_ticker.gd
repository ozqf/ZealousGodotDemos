# Main AI class run by mob_base when it has a target (and isn't dead or stunned!)
extends Node3D
class_name AITicker

const Enums = preload("res://src/enums.gd")

const STATE_INITIAL:int = -1
const STATE_MOVE:int = 0
const STATE_WINDUP:int = 1
const STATE_ATTACK:int = 2
const STATE_WINDDOWN:int = 3
const STATE_REPEAT_WINDUP:int = 4
# const STATE_REPEAT_WINDDOWN:int = 5

const MOVEMODE_CHARGE:int = 0
const MOVEMODE_EVADE:int = 1
const MOVEMODE_FLEE:int = 2
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

var fleeTime:float = 0

var moveAndAttack:bool = true

var _attackIndex:int = -1
var _attackMode:int = 0
var _revengeAttack:bool = false

var lastTarPos:Vector3 = Vector3()

var _mob

func get_debug_text() -> String:
	var txt:String = "-AI Ticker-\nState: " + str(_state) + "\n"
	txt += "Is sniper" + str(isSniper) + "\n"
	txt += "Flee time: " + str(fleeTime) + " vs max: " + str(_mob.fleeBoredomSeconds) + "\n"
	return txt

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

func _fire_attack(attack:MobAttack, tarPos:Vector3) -> void:
	attack.fire(tarPos)

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
		if _mob.aimLaser != null:
			_mob.aimLaser.off()
	elif _state == STATE_WINDUP:
		_mob.sprite.play_animation("aim")
		var atk = get_attack()
		_tick = atk.windUpTime
		# look at target
		_mob.head.look_at(lastTarPos, Vector3.UP)
		set_rotation_to_target(lastTarPos)
		_mob.emit_mob_event("windup", -1)
		if _mob.aimLaser != null && atk.showAimLaser:
			_mob.aimLaser.on(_tick, false)
		if _mob.omniCharge != null && atk.showOmniCharge:
			_mob.omniCharge.on(_tick)
	elif _state == STATE_ATTACK:
		_mob.sprite.play_animation("shoot")
		_mob.emit_mob_event("shoot", -1)
		var atk:MobAttack = _mob.attacks[_attackIndex]
		var tarPos:Vector3
		if atk.useLastSeenPosition:
			tarPos = lastTarPos
		else:
			tarPos = lastTarPos
		#atk.fire(lastTarPos)
		_fire_attack(atk, lastTarPos)
		_tick = atk.attackAnimTime
	elif _state == STATE_WINDDOWN:
		if _mob.aimLaser != null:
			_mob.aimLaser.off()
		_mob.sprite.play_animation("aim")
		_tick = get_attack().windDownTime
	elif _state == STATE_REPEAT_WINDUP:
		var atk:MobAttack = _mob.attacks[_attackIndex]
		if _mob.aimLaser != null && !atk.showAimLaserDuringRepeat:
			_mob.aimLaser.off()
		_mob.sprite.play_animation("aim")
		_tick = get_attack().repeatTime
	# elif _state == STATE_REPEAT_WINDDOWN
	# 	pass

func _set_last_tar_pos(_tickInfo:AITickInfo) -> void:
	lastTarPos = _tickInfo.targetPos
	# override with last seen position if attack
	# says to use that.
	if _attackIndex >= 0:
		var atk:MobAttack = _mob.attacks[_attackIndex]
		if atk.useLastSeenPosition:
			lastTarPos = _tickInfo.lastSeenTargetPos

# return true if state change was handled
# false to allow base function to handle it instead
func custom_change_state(_newState:int, _oldState:int) -> bool:
	return false

# returns true if an attack started
func _start_attack(_delta:float, _tickInfo:AITickInfo) -> bool:
	_attackIndex = _select_attack(_tickInfo)
	if _attackIndex < 0:
		# oh dear, no usable attack
		return false
	# maxCycles = _mob.attacks[_attackIndex].attackCount
	_cycles = 0
	_set_last_tar_pos(_tickInfo)
	# lastTarPos = _tickInfo.targetPos
	# _mob.face_target_flat(lastTarPos)
	change_state(STATE_WINDUP)
	set_rotation_to_target(_tickInfo.targetPos)
	return true

func _check_attack_cooldown(att:MobAttack) -> bool:
	var time:float = _mob.time
	if att.cooldown > 0:
		var nextUsable:float = att.lastSelectTime + att.cooldown
		if nextUsable > time:
			return false
	return true

# iterate attacks array and select the first that meets
# all necessary criteria
func _select_attack(_tickInfo:AITickInfo) -> int:
	var time:float = _mob.time
	var dist:float = _tickInfo.trueDistanceSqr
	var numAttacks:int = _mob.attacks.size()
	for _i in range (0, numAttacks):
		var att:MobAttack = _mob.attacks[_i]
		if !att.enabled:
			continue
		if !_check_attack_cooldown(att):
			continue
		# if att.cooldown > 0:
		# 	var nextUsable:float = att.lastSelectTime + att.cooldown
		# 	if nextUsable > time:
		# 		continue
		if att.requiresLos && !_tickInfo.canSeeTarget:
			continue
		if dist < (att.minUseRange * att.minUseRange):
			continue
		elif dist > (att.maxUseRange * att.maxUseRange):
			continue
		att.lastSelectTime = time
		return _i
	return -1

func set_rotation_to_movement() -> void:
	_mob.sprite.yawDegrees = rad_to_deg(_mob.motor.moveYaw)
	# set_rotation_to_target(_mob.motor.moveTargetPos)

func set_rotation_to_target(pos:Vector3) -> void:
	var yawDegrees:float = ZqfUtils.yaw_between(_mob.global_transform.origin, pos)
	yawDegrees = rad_to_deg(yawDegrees)
	_mob.sprite.yawDegrees = yawDegrees

func _attack_move(_delta:float) -> void:
	if isSniper:
		return
	if !_mob.attacks[_attackIndex].allowMovement:
		return
	if _moveMode == MOVEMODE_FLEE:
		_mob.motor.move_idle(_delta)
		return
	if moveAndAttack:
		# _mob.motor.move_hunt(_delta)
		_mob.motor.move_evade(_delta)
		return
	_mob.motor.move_idle(_delta)

func validate_move_target(_delta:float, _tickInfo:AITickInfo) -> void:
	if isSniper:
		return
	
	var isNotInjured:bool = _tickInfo.healthPercentage >= 50
	var agent = _mob.motor.get_agent()

	var canFlee:bool = fleeTime < _mob.fleeBoredomSeconds
	
	if isNotInjured || !canFlee:
		if _mob.roleId == Enums.CombatRole.Ranged:
			# find a sniping position
			if agent.objectiveNode == null || !agent.objectiveNode.sniperSpot:
				if AI.find_sniper_position(agent):
					_mob.motor.set_move_target(agent.target)
					if AI.verboseMobs:
						print("Sniper move target is " + str(agent.target) + " waypoint " + str(agent.objectiveNode.index))
					return
				else:
					# fall back to just being a charger
					if AI.verboseMobs:
						print("Mob can't find a sniper position!")
					_mob.motor.set_move_target(_tickInfo.targetPos)
		else:
			var distMode:int = 0
			if _tickInfo.canSeeTarget:
				_mob.motor.set_move_target(_tickInfo.targetPos)
			else:
				# can't see target, move directly toward them
				_mob.motor.set_move_target(_tickInfo.targetPos)
		pass
	else:
		# "Runaway. Runaway. Run Children. Run for your life!
		# Runaway. Runaway. Run children. Here it comes. I said run. Alright"
		if agent.objectiveNode == null || agent.objectiveNode.canSeePlayer:
			_moveMode = MOVEMODE_FLEE
			if AI.find_flee_position(_mob.motor.get_agent()):
				_mob.motor.set_move_target(_mob.motor.get_agent().target)
	pass

func _check_for_attack_start(_tickInfo:AITickInfo) -> bool:
	if _tick <= 0 && _tickInfo.trueDistanceSqr <= (999 * 999) && _tickInfo.canSeeTarget:
		return true
	return false

func custom_tick_state(_delta:float, _tickInfo:AITickInfo) -> void:
	_tickInfo.moveThinkTick -= _delta
	validate_move_target(_delta, _tickInfo)
	
	# run boredom timer if we are fleeing but can't see the player
	if _moveMode == MOVEMODE_FLEE && !_tickInfo.canSeeTarget:
		fleeTime += _delta
	
	if _state == STATE_MOVE:
		if isSniper:
			# try and attack. if we can't, hunt.
			if !_start_attack(_delta, _tickInfo):
				if !_mob.motor.move_hunt(_delta):
					print("AITicker - failed to hunt move")
				set_rotation_to_movement()
			return
		# if _tickInfo.healthPercentage > 50:
		# 	_mob.motor.set_move_target(_tickInfo.targetPos)
		# 	_mob.motor.set_move_target_forward(_tickInfo.targetForward)
		# else:
		# 	# pick a flee point
		# 	if AI.find_flee_position(_mob.motor.get_agent()):
		# 		_mob.motor.set_move_target(_mob.motor.get_agent().target)
		# 	pass
		if _tickInfo.trueDistanceSqr > (3 * 3):
			if !_mob.motor.move_hunt(_delta):
				print("AITicker - failed to hunt move")
			set_rotation_to_movement()
		# if _check_for_attack_start(_tickInfo):
			# print("AI ticker - attack")
		_start_attack(_delta, _tickInfo)
	
	elif _state == STATE_WINDUP || _state == STATE_REPEAT_WINDUP:
		_attack_move(_delta)
		if get_attack().faceTargetDuringWindup:
			_mob.head.look_at(_tickInfo.lastSeenTargetPos, Vector3.UP)
			set_rotation_to_target(_tickInfo.lastSeenTargetPos)
			# lastTarPos = _tickInfo.lastSeenTargetPos
			_set_last_tar_pos(_tickInfo)
			# _mob.face_target_flat(lastTarPos)
		if _tick <= 0:
			change_state(STATE_ATTACK)
	elif _state == STATE_ATTACK:
		_attack_move(_delta)
		# _mob.face_target_flat(_tickInfo.targetPos)
		if _tick <= 0:
			_cycles += 1
			if _cycles < get_attack().attackCount:
				change_state(STATE_REPEAT_WINDUP)
				# _tick = get_attack().repeatTime
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
	
