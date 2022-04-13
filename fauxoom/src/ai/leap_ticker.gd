extends AITicker

const LEAP_STATE:int = -2

onready var _area:Area = $Area
onready var _shape:CollisionShape = $Area/CollisionShape

var _hitInfo:HitInfo = null

var _leapStart:Vector3 = Vector3()
var _leapEnd:Vector3 = Vector3()
var _leapTick:float = 0.0
var _leapTime:float = 0.5
var _leapRecoverTime:float = 0.5
var _leapRange:float = 20.0

func custom_init_b() -> void:
	_hitInfo = Game.new_hit_info()
	_hitInfo.attackTeam = Interactions.TEAM_ENEMY
#	_mob.motor.speed = 8
	_damage_area_off()
	var _err = _area.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body:PhysicsBody) -> void:
	# can touch self!
	if body == _mob:
		return
	# print("Hit!")
	_damage_area_off()
	Interactions.hit(_hitInfo, body)

func _damage_area_off() -> void:
	_area.visible = false
	_shape.disabled = true

func stop_hunt() -> void:
	_damage_area_off()
	.stop_hunt()

func custom_tick(_delta:float, _targetInfo:AITickInfo) -> void:
	_tick -= _delta
	if _state == STATE_MOVE:
		var pos:Vector3 = _mob.global_transform.origin
		var tar:Vector3 = _targetInfo.targetPos
		
		var dist:float = ZqfUtils.flat_distance_between(pos, tar)
		self.set_rotation_to_movement()
		if dist < _leapRange:
			if _tick <= 0:
			# print("LEAP!")

				# new - select a spot and leap to it
				var leapTarget:Vector3 = AI.find_closest_navmesh_point(tar)
				var losOrigin:Vector3 = pos
				var losDest:Vector3 = leapTarget
				losDest.y += 1.0
				losOrigin.y += 1.0
				var hasLoS:bool = ZqfUtils.los_check(self, losOrigin, losDest, Interactions.WORLD)
				if hasLoS:
					Game.spawn_ground_target(leapTarget, 1)
					_leapStart = pos
					_leapEnd = leapTarget
					_mob.sprite.play_animation("leap")
					_leapTick = 0.0
					_tick = 0
					# print("Start leap from " + str(_leapStart) + " to " + str(_leapEnd))
					change_state(LEAP_STATE)
				else:
					# Game.spawn_impact_debris(leapTarget, Vector3.UP, 5, 10, 5)
					_mob.motor.move_idle(_delta)
					_mob.motor.set_move_target(_targetInfo.targetPos)
					_mob.motor.set_move_target_forward(_targetInfo.flatForward)
					_mob.motor.move_hunt(_delta)
					_tick =  0.25

				# old code, lunge across to target
				# change_state(LEAP_STATE)
				# _mob.sprite.play_animation("leap")
				# _mob.motor.set_move_target(_targetInfo.targetPos)
				# _mob.motor.set_move_target_forward(_targetInfo.flatForward)
				# _mob.motor.start_leap(_delta, 14)
				# _area.visible = true # just for debugging
				# _shape.disabled = false
			else:
				_mob.motor.move_idle(_delta)
		else:
			_mob.motor.set_move_target(_targetInfo.targetPos)
			_mob.motor.set_move_target_forward(_targetInfo.flatForward)
			_mob.motor.move_hunt(_delta)
		# if _tick <= 0:
		# 	_cycles = 0
		# 	lastTarPos = _targetInfo.position
		# 	_mob.face_target_flat(lastTarPos)
		# 	change_state(STATE_WINDUP)
	elif _state == LEAP_STATE:
		_leapTick += _delta
		var weight:float = _leapTick / _leapTime
		var pos:Vector3 = _leapStart.linear_interpolate(_leapEnd, weight)
		# print("Lerp to pos" + str(pos))
		_mob.global_transform.origin = pos
		if _leapTick > _leapTime:
			_damage_area_off()
			change_state(STATE_WINDDOWN)
			_tick = _leapRecoverTime # 1.25
		pass
		# _mob.motor.move_leap(_delta, 14)
		# #_mob.motor.move_idle(_delta)
		# if _tick <= 0:
		# 	_damage_area_off()
		# 	change_state(STATE_WINDDOWN)
		# 	_tick = 1.25
	elif _state == STATE_WINDDOWN:
		_mob.motor.move_idle(_delta)
		if _tick <= 0:
			change_state(STATE_MOVE)
	else:
		change_state(STATE_MOVE)
	
