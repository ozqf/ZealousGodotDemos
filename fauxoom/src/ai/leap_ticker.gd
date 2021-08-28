extends AITicker

const LEAP_STATE:int = -1

onready var _area:Area = $Area
onready var _shape:CollisionShape = $Area/CollisionShape

var _hitInfo:HitInfo = null

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
	print("Hit!")
	_damage_area_off()
	Interactions.hit(_hitInfo, body)

func _damage_area_off() -> void:
	_area.visible = false
	_shape.disabled = true

func stop_hunt() -> void:
	_damage_area_off()
	.stop_hunt()

func custom_tick(_delta:float, _targetInfo:Dictionary) -> void:
	_tick -= _delta
	if _state == STATE_MOVE:
		var pos:Vector3 = _mob.global_transform.origin
		var tar:Vector3 = _targetInfo.position
		
		var dist:float = ZqfUtils.flat_distance_between(pos, tar)
		self.set_rotation_to_movement()
		if dist < 8:
			if _tick <= 0:
			# print("LEAP!")
				change_state(LEAP_STATE)
				_mob.sprite.play_animation("leap")
				_mob.motor.set_move_target(_targetInfo.position)
				_mob.motor.set_move_target_forward(_targetInfo.forward)
				_mob.motor.start_leap(_delta, 14)
				# _area.visible = true # just for debugging
				_shape.disabled = false
				_tick = 0.5
			else:
				_mob.motor.move_idle(_delta)
		else:
			_mob.motor.set_move_target(_targetInfo.position)
			_mob.motor.set_move_target_forward(_targetInfo.forward)
			_mob.motor.move_hunt(_delta)
		# if _tick <= 0:
		# 	_cycles = 0
		# 	lastTarPos = _targetInfo.position
		# 	_mob.face_target_flat(lastTarPos)
		# 	change_state(STATE_WINDUP)
	elif _state == LEAP_STATE:
		_mob.motor.move_leap(_delta, 14)
		#_mob.motor.move_idle(_delta)
		if _tick <= 0:
			_damage_area_off()
			change_state(STATE_WINDDOWN)
			_tick = 1.25
	elif _state == STATE_WINDDOWN:
		_mob.motor.move_idle(_delta)
		if _tick <= 0:
			change_state(STATE_MOVE)
	else:
		change_state(STATE_MOVE)
	
