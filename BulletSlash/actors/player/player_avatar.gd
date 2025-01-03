extends CharacterBody3D
class_name PlayerAvatar

const PARRY_WINDOW:float = 0.5
const ANIM_BLOCK:String = "punch_charge_stance"

@onready var _cursor:Node3D = $cursor
@onready var _aimPlanePos:Node3D = $aim_plane_pos
@onready var _display:Node3D = $display
@onready var _animator:AnimationPlayer = $display/AnimationPlayer
@onready var _rightHand:Node3D = $display/right_hand
@onready var _leftHand:Node3D = $display/left_hand
@onready var _rightBatonArea:Area3D = $display/right_hand/right_baton/hitbox
@onready var _leftBatonArea:Area3D = $display/left_hand/left_baton/hitbox
@onready var _hudInfo:HudInfo = $HudInfo
@onready var _hitbox:Node = $display/hitbox
var _groundPlane:Plane = Plane()

enum AttackInputDir { Neutral, Forward, Backward }

var _stance:PlayerAttacks.Stance = PlayerAttacks.Stance.Punch
var _pendingStance:PlayerAttacks.Stance = PlayerAttacks.Stance.Mixed
var _inMoveRecovery:bool = false

var _timeSinceLastLookAction:float = 0.0

var _targetInfo:TargetInfo
var _lastAimPoint:Vector3 = Vector3()
var _animationRepeatPosition:float = 0.0
var _nextShotRight:bool = true

var _selfTime:float = 0.0
var _animHistory:PackedStringArray = PackedStringArray()
var _animHistoryTimes:PackedFloat32Array = PackedFloat32Array()
var _animHistorySequence:int = 0

var _hitInfo:HitInfo

var _dashInput:Vector2 = Vector2()

var _refireTick:float = 0.0
var _attackLockoutTick:float = 0.0
var _timeBlocking:float = 0.0

var _tryAttackSequenceTick:float = 0.0

var _moves:Dictionary
var _lastAttack:Dictionary = {}
var _attack1Buffered:bool = false
var _attack2Buffered:bool = false

var _maxLoadedShots:int = 20
var _loadedShots:int = 0

func _ready() -> void:
	# however many slots we want
	for i in range (0, 8):
		_animHistory.push_back("")
		_animHistoryTimes.push_back(0)
	_animHistorySequence = 0
	_loadedShots = _maxLoadedShots
	_moves = PlayerAttacks.get_moves()
	_hitInfo = Game.new_hit_info()
	_hitInfo.sourceTeamId = Game.TEAM_ID_PLAYER
	_hitInfo.damageTeamId = Game.TEAM_ID_PLAYER
	_targetInfo = Game.new_target_info()
	_return_to_idle_animation()
	_animator.connect("current_animation_changed", _on_weapon_animation_changed)
	_rightBatonArea.connect("area_entered", _on_area_entered_right_baton)
	_leftBatonArea.connect("area_entered", _on_area_entered_left_baton)
	var grp = Game.GROUP_GAME_EVENTS
	var fn = Game.GAME_EVENT_FN_PLAYER_SPAWNED
	get_tree().call_group(grp, fn, self)
	_hitbox.set_subject(self)

##########################################################################
# Do hits
##########################################################################
func _hit_target(target:Area3D, weaponArea:Area3D) -> void:
	_hitInfo.position = weaponArea.global_position
	if !_lastAttack.is_empty() && _lastAttack.damageType == GameMain.DAMAGE_TYPE_SLASH:
		# "...and the blood will go fftsssssssssssh..."
		_hitInfo.direction = -weaponArea.global_transform.basis.x
	else:
		_hitInfo.direction = weaponArea.global_transform.basis.z
	var result:int = Game.try_hit(_hitInfo, target)
	if result == Game.HIT_VICTIM_RESPONSE_PARRIED:
		# oh dear
		apply_parry()
		pass

func _on_area_entered_right_baton(_area:Area3D) -> void:
	_hit_target(_area, _rightBatonArea)

func _on_area_entered_left_baton(_area:Area3D) -> void:
	_hit_target(_area, _leftBatonArea)

func _set_area_on(area:Area3D, flag:bool) -> void:
	area.monitoring = flag
	area.monitorable = flag

##########################################################################
# Take hit
##########################################################################
func hit(_incomingHit:HitInfo) -> int:
	if _incomingHit.damageTeamId == Game.TEAM_ID_PLAYER:
		return Game.HIT_VICTIM_RESPONSE_SAME_TEAM
	if _incomingHit.sourceTeamId == Game.TEAM_ID_PLAYER:
		return Game.HIT_VICTIM_RESPONSE_SAME_TEAM
	
	var blockTime:float = get_block_time()
	if blockTime > 0.0:
		if blockTime < PARRY_WINDOW:
			var weight:float = 1.0 - (blockTime / PARRY_WINDOW)
			_incomingHit.responseParryWeight = weight
			return Game.HIT_VICTIM_RESPONSE_PARRIED
		return Game.HIT_VICTIM_RESPONSE_BLOCKED
	print("Player hit")
	# oh dear
	apply_parry()
	return 1

func get_block_time() -> float:
	if _animator.current_animation != ANIM_BLOCK:
		return 0.0
	return _timeBlocking

func apply_parry() -> void:
	print("Player was parried!")
	_attackLockoutTick = 1.5
	call_deferred("right_baton_off")
	call_deferred("left_baton_off")
	_animator.play("parried")

##########################################################################
# attack animations
##########################################################################
func _on_weapon_animation_changed(_animName:String) -> void:
	match _animName:
		"punch_idle", "blade_idle", "blaster_idle":
			return
	_animHistorySequence += 1
	var historyLength:int = _animHistory.size()
	_animHistory[_animHistorySequence % historyLength] = _animName
	_animHistoryTimes[_animHistorySequence % historyLength] = _selfTime
	_tryAttackSequenceTick = 0.2

func start_move(moveName:String) -> void:
	if !_moves.has(moveName):
		print("Move " + moveName + " not found")
		return
	
	var candidateMove:Dictionary = _moves[moveName]
	_lastAttack = candidateMove
	var numAnimations:int = candidateMove.animations.size()
	if numAnimations == 0:
		return
	
	_animator.play(candidateMove.animations[0])
	for i in range (1, numAnimations):
		_animator.queue(candidateMove.animations[i])
	
	# apply
	look_at_aim_point()
	_timeSinceLastLookAction = 0.0
	_lastAttack = candidateMove
	_attack1Buffered = false
	_attack2Buffered = false
	_inMoveRecovery = false
	
	#_animator.play(_lastAttack.animation)
	_animator.queue(_lastAttack.idleAnimation)
	_hitInfo.damageType = _lastAttack.damageType

func _return_to_idle_animation() -> void:
	_animator.clear_queue()
	match _stance:
		PlayerAttacks.Stance.Blade:
			_animator.play("blade_idle")
		PlayerAttacks.Stance.Gun:
			_animator.play("blaster_idle")
		_:
			_animator.play("punch_idle")

func _queue_idle_animation() -> void:
	match _stance:
		PlayerAttacks.Stance.Blade:
			_animator.queue("blade_idle")
		PlayerAttacks.Stance.Gun:
			_animator.queue("blaster_idle")
		_:
			_animator.queue("punch_idle")

func check_attack_chain_cancel() -> void:
	if !_attack1Buffered: # && !_attack2Buffered:
		_return_to_idle_animation()
		return
	# continue animation but update direction
	_attack1Buffered = false
	#_attack2Buffered = false
	look_at_aim_point()

func mark_repeat_time() -> void:
	_animationRepeatPosition = _animator.current_animation_position
	#print("Mark repeat " + str(_animationRepeatPosition))

func check_animation_loop() -> void:
	if _animator.current_animation == "blaster_reload":
		if Input.is_action_pressed("attack_3"):
			_animator.seek(_animationRepeatPosition, true, true)
		return
	if !Input.is_action_pressed("attack_1"): # && !Input.is_action_pressed("attack_2"):
		return
	if !consume_shot_for_loop(_lastAttack[PlayerAttacks.FIELD_SHOTS_CONSUMED_ON_LOOP]):
		return
	_animator.seek(_animationRepeatPosition, true, true)

func consume_shot_for_loop(required:int) -> bool:
	if required <= 0:
		return true
	if _loadedShots >= required:
		_loadedShots -= required
		return true
	return false

func _load_shot() -> bool:
	if _loadedShots >= _maxLoadedShots:
		_loadedShots = _maxLoadedShots
		return false
	_loadedShots += 1
	return true

func load_shot_from_right_spin() -> void:
	sfx_right_baton_swish()
	if !_load_shot():
		return
	var pos:Vector3 = _rightBatonArea.global_position
	var dir:Vector3 = -_rightBatonArea.global_transform.basis.x
	Game.spawn_gfx_ejected_shell(pos, dir)
	Game.sound.play_shotgun_load(pos)

func load_shot_from_left_spin() -> void:
	sfx_left_baton_swish()
	if !_load_shot():
		return
	var pos:Vector3 = _leftBatonArea.global_position
	var dir:Vector3 = -_leftBatonArea.global_transform.basis.x
	Game.spawn_gfx_ejected_shell(pos, dir)
	Game.sound.play_shotgun_load(pos)

###############################################
# Shoot right baton
func shoot_right_forward() -> void:
	if !consume_shot_for_loop(1):
		return
	var t:Transform3D = _rightHand.global_transform
	_fire_scatter(t)
	Game.spawn_gfx_blaster_muzzle(t.origin, -t.basis.z)

func shoot_right_right() -> void:
	if !consume_shot_for_loop(1):
		return
	var t:Transform3D = _rightHand.global_transform
	t = t.looking_at(t.origin + t.basis.x)
	_fire_scatter(t)
	Game.spawn_gfx_blaster_muzzle(t.origin, -t.basis.z)
	return

func shoot_right_left() -> void:
	if !consume_shot_for_loop(1):
		return
	var t:Transform3D = _rightHand.global_transform
	t = t.looking_at(t.origin + -t.basis.x)
	_fire_scatter(t)
	Game.spawn_gfx_blaster_muzzle(t.origin, -t.basis.z)

###############################################
# Shoot left baton
func shoot_left_forward() -> void:
	if !consume_shot_for_loop(1):
		return
	var t:Transform3D = _leftHand.global_transform
	_fire_scatter(t)
	Game.spawn_gfx_blaster_muzzle(t.origin, -t.basis.z)

func shoot_left_right() -> void:
	if !consume_shot_for_loop(1):
		return
	pass

func shoot_left_left() -> void:
	if !consume_shot_for_loop(1):
		return
	pass

###############################################
# animation callbacks
###############################################
func set_recovering_on() -> void:
	_inMoveRecovery = true

func set_recovering_off() -> void:
	_inMoveRecovery = false

func right_baton_on() -> void:
	_set_area_on(_rightBatonArea, true)

func right_baton_off() -> void:
	_set_area_on(_rightBatonArea, false)

func left_baton_on() -> void:
	_set_area_on(_leftBatonArea, true)

func left_baton_off() -> void:
	_set_area_on(_leftBatonArea, false)

func get_target_info() -> TargetInfo:
	return _targetInfo

func refresh_target_info() -> void:
	_targetInfo.t = self.global_transform
	_targetInfo.inAction = is_view_locked()

func sfx_right_baton_swish() -> void:
	Game.sound.play_quick_blade_swing(_rightBatonArea.global_position)

func sfx_left_baton_swish() -> void:
	Game.sound.play_quick_blade_swing(_leftBatonArea.global_position)

##########################################################################
# attacks
##########################################################################
func look_at_aim_point() -> void:
	var displayPos:Vector3 = _lastAimPoint
	displayPos.y = _display.global_position.y
	_display.look_at(displayPos, Vector3.UP)

func look_in_move_dir() -> void:
	if !self.velocity.is_zero_approx():
		var v:Vector3 = self.velocity
		v.y = _display.global_position.y
		var displayPos:Vector3 = _display.global_position + v.normalized()
		_display.look_at(displayPos, Vector3.UP)

func is_view_locked() -> bool:
	match _animator.current_animation:
		"", "punch_idle", "blaster_idle", "blade_idle", "blaster_shoot_left", "blaster_shoot_right", "punch_dash", "blaster_reload":
			return false
		"punch_spin_test":
			return false
		ANIM_BLOCK:
			return false
		null:
			return false
		_:
			return true


func is_attacking() -> bool:
	match _animator.current_animation:
		null, "", "punch_idle", "blaster_idle", "blade_idle", "punch_dash", ANIM_BLOCK:
			return false
		_:
			return true

func is_move_speed_limited() -> bool:
	match _animator.current_animation:
		"", "punch_idle", "blaster_idle", "blade_idle", "punch_dash":
			return false
		"blaster_reload":
			return false
		#"blaster_shoot_left", "blaster_shoot_right":
		#	return false
		_:
			return true

func _step_dash(_delta:float) -> void:
	var move:Vector3 = Vector3(_dashInput.x, 0, _dashInput.y) * 10.0
	self.velocity = move
	self.move_and_slide()

func _fire_scatter(t:Transform3D) -> void:
	Game.sound.play_shotgun_fire(t.origin)
	var forward:Vector3 = -t.basis.z
	_fire_projectile(t.origin, forward)
	forward = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, -1200, 0)
	_fire_projectile(t.origin, forward)
	forward = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, 1200, 0)
	_fire_projectile(t.origin, forward)

func _fire_projectile(origin:Vector3, forward:Vector3) -> void:
	_timeSinceLastLookAction = 0.0
	var prj:PrjBasic = Game.spawn_prj_basic()
	var info:ProjectileLaunchInfo = prj.get_launch_info()
	info.origin = origin #_rightBatonArea.global_position
	info.forward = forward #-_display.global_transform.basis.z
	prj.launch()
	_refireTick = 0.5

func _get_attack_dir(inputVec:Vector2) -> AttackInputDir:
	var inputDir:Vector3 = Vector3(inputVec.x, 0, inputVec.y)
	var dot:float = inputDir.dot(-_display.global_transform.basis.z)
	if dot > 0.0:
		return AttackInputDir.Forward
	elif dot < 0.0:
		return AttackInputDir.Backward
	return AttackInputDir.Neutral

func _check_for_mixed_stance_move_start(isAttacking:bool, atkDir:AttackInputDir, _delta:float) -> void:
	if isAttacking:
		return
	var atkOneJustOn:bool = Input.is_action_just_pressed("attack_1")
	var atkTwoJustOn:bool = Input.is_action_just_pressed("attack_2")
	#var atkThree:bool = Input.is_action_pressed("attack_3")
	if atkOneJustOn:
		start_move("slash_sequence")
	elif atkTwoJustOn:
		start_move("punch_jab_left")

func _check_for_blade_stance_move_start(isAttacking:bool, atkDir:AttackInputDir, _delta:float) -> void:
	if isAttacking:
		return
	var atkOneJustOn:bool = Input.is_action_just_pressed("attack_1")
	var atkTwoOn:bool = Input.is_action_pressed("attack_2")
	#var atkThree:bool = Input.is_action_pressed("attack_3")

	# quick swing combo
	if !atkTwoOn:
		if atkOneJustOn:
			start_move("slash_sequence")
		return
	
	# 2 is held, look for 1 taps to release
	if atkOneJustOn:
		if atkDir == AttackInputDir.Forward:
			start_move("shredder")
		elif atkDir == AttackInputDir.Backward:
			start_move("hold_forward_spin")
		else:
			start_move("slash_sequence")

func _check_for_punch_stance_move_start(isAttacking:bool, atkDir:AttackInputDir, _delta:float) -> void:
	if isAttacking:
		return
	#var historySize:int = _animHistory.size()
	var atkOneJustOn:bool = Input.is_action_just_pressed("attack_1")
	#var atkTwoJustOn:bool = Input.is_action_just_pressed("attack_2")
	#var atkOneOn:bool = Input.is_action_pressed("attack_1")
	var atkTwoOn:bool = Input.is_action_pressed("attack_2")
	
	# release 2 combo starter
	#if Input.is_action_just_released("attack_2"):
	#	if atkDir == AttackInputDir.Forward:
	#		start_move("shredder")
	#		return
	#	elif atkDir == AttackInputDir.Backward:
	#		start_move("double_spin")
	#	else:
	#		start_move("slash_sequence")
	#	return

	# tapping 1 no 2 - just a quick jab combo
	if !atkTwoOn:
		if atkOneJustOn:
			start_move("punch_jab_left")
		return
	
	# 2 is held, look for 1 taps to release
	if atkOneJustOn:
		if atkDir == AttackInputDir.Forward:
			start_move("punch_jet_leap")
		elif atkDir == AttackInputDir.Backward:
			start_move("punch_machine_gun")
		else:
			start_move("punch_straight_right")

func _check_for_punch_stance_move_start_2(isAttacking:bool, atkDir:AttackInputDir, _delta:float) -> void:
	var historySize:int = _animHistory.size()
	var punchOn:bool = Input.is_action_just_pressed("attack_1")
	var slashOn:bool = Input.is_action_just_pressed("attack_2")
	if _tryAttackSequenceTick > 0.0:
		if !isAttacking && (punchOn || slashOn):
			var lastWasJab:bool = _animHistory[(_animHistorySequence - 1) % historySize] == "punch_jab_left"
			# idle anim in between!
			var lastLastWasJab:bool = _animHistory[(_animHistorySequence - 3) % historySize] == "punch_jab_left"
			if lastWasJab && lastLastWasJab:
				if punchOn:
					if atkDir == AttackInputDir.Forward:
						start_move("punch_straight_right")
					elif atkDir == AttackInputDir.Backward:
						start_move("punch_machine_gun")
					else:
						start_move("punch_jab_left")
				elif slashOn:
					pass
			else:
				start_move("punch_jab_left")
	else:
		# something new eh
		if !isAttacking && Input.is_action_just_pressed("attack_1"):
			start_move("punch_jab_left")
		if !isAttacking && Input.is_action_just_pressed("attack_2"):
			start_move("slash_sequence")

func _check_for_punch_stance_move_start_1(isAttacking:bool, atkDir:AttackInputDir, _delta:float) -> void:
	if !isAttacking && Input.is_action_just_pressed("attack_1"):
		look_at_aim_point()
		#var historySize:int = _animHistory.size()
		
		if _tryAttackSequenceTick > 0.0 && !_lastAttack.is_empty() && _lastAttack.name == "punch_jab_left":
			start_move("punch_straight_right")
		else:
			start_move("punch_jab_left")
		#match atkDir:
		#	AttackInputDir.Forward:
		#		start_move("punch_straight_right")
		#		pass
		#	AttackInputDir.Backward:
		#		start_move("punch_machine_gun")
		#	_:
		#		start_move("punch_jab_left")
	if !isAttacking && Input.is_action_just_pressed("attack_2"):
		look_at_aim_point()
		match atkDir:
			AttackInputDir.Forward:
				look_at_aim_point()
				start_move("shredder")
			AttackInputDir.Backward:
				look_at_aim_point()
				start_move("double_spin")
			_:
				look_at_aim_point()
				start_move("slash_sequence")

func _gfx_muzzle_from_baton(baton:Area3D, hand:Node3D) -> void:
	# due to animation method call sync, sometimes the baton is not
	# angled how we would like. so use the hand as the angle
	# and baton as position
	var t:Transform3D = hand.global_transform
	t.origin = baton.global_position
	Game.spawn_gfx_blaster_muzzle(t.origin, -t.basis.z)

func gfx_muzzle_from_right_baton() -> void:
	_gfx_muzzle_from_baton(_rightBatonArea, _rightHand)

func gfx_muzzle_from_left_baton() -> void:
	_gfx_muzzle_from_baton(_leftBatonArea, _leftHand)

##########################################################################
# life time
##########################################################################

func _broadcast_hud_info() -> void:
	_hudInfo.playerWorldPosition = self.global_position
	
	_hudInfo.shotCount = _loadedShots
	_hudInfo.maxShotCount = _maxLoadedShots
	
	var grp:String = HudInfo.GROUP_NAME
	var fn:String = HudInfo.FN_HUD_INFO_BROADCAST
	self.get_tree().call_group(grp, fn, _hudInfo)

func _exit_tree():
	var grp = Game.GROUP_GAME_EVENTS
	var fn = Game.GAME_EVENT_FN_PLAYER_DESPAWNED
	get_tree().call_group(grp, fn, self)

func _physics_process(_delta:float) -> void:
	
	# house-keeping
	_selfTime += _delta
	_timeSinceLastLookAction += _delta
	_timeBlocking += _delta
	_tryAttackSequenceTick -= _delta
	_refireTick -= _delta
	_attackLockoutTick -= _delta
	refresh_target_info()
	_broadcast_hud_info()

	# inputs
	if Input.is_action_just_pressed("slot_1"):
		_pendingStance = PlayerAttacks.Stance.Blade
	elif Input.is_action_just_pressed("slot_2"):
		_pendingStance = PlayerAttacks.Stance.Punch
	elif Input.is_action_just_pressed("slot_3"):
		_pendingStance = PlayerAttacks.Stance.Gun
	elif Input.is_action_just_pressed("slot_4"):
		_pendingStance = PlayerAttacks.Stance.Mixed
	
	var viewLocked:bool = is_view_locked()
	var inputVec:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var atkDir:AttackInputDir = _get_attack_dir(inputVec)
	if _animator.current_animation == "punch_dash":
		_step_dash(_delta)
		return
	
	if !viewLocked && _stance != _pendingStance:
		_stance = _pendingStance
		_return_to_idle_animation()
	
	var canEvade:bool = true
	if _rightBatonArea.monitoring:
		canEvade = false
	if _leftBatonArea.monitoring:
		canEvade = false
	#if viewLocked:
	#	canEvade = false
	if Input.is_action_just_pressed("dash") && canEvade:
		_dashInput = inputVec
		_animator.play("punch_dash")
		_queue_idle_animation()
		_step_dash(_delta)
		return
	
	var isAttacking:bool = is_attacking() #viewLocked
	
	# stance agnostic block
	if !isAttacking:
		if Input.is_action_pressed("attack_2"):
			if !_animator.current_animation == ANIM_BLOCK:
				_animator.play(ANIM_BLOCK)
				_timeBlocking = 0.0
				_timeSinceLastLookAction = 0.0
		elif _animator.current_animation == ANIM_BLOCK:
			if _stance == PlayerAttacks.Stance.Punch:
				_animator.play("punch_idle")
			else:
				_animator.play("blade_idle")

	if isAttacking:
		if Input.is_action_just_pressed("attack_1"):
			_attack1Buffered = true
		elif Input.is_action_just_pressed("attack_2"):
			_attack2Buffered = true
	
	if _attackLockoutTick <= 0.0:
		match _stance:
			PlayerAttacks.Stance.Mixed:
				_check_for_mixed_stance_move_start(isAttacking, atkDir, _delta)
				pass
			################################################################
			# Blade
			PlayerAttacks.Stance.Blade:
				_check_for_blade_stance_move_start(isAttacking, atkDir, _delta)
			################################################################
			# Gun
			PlayerAttacks.Stance.Gun:
				if !isAttacking && _refireTick <= 0.0:
					if Input.is_action_pressed("attack_1"):
						if _loadedShots > 0:
							_loadedShots -= 1
							if _nextShotRight:
								_animator.play("blaster_shoot_right")
								_gfx_muzzle_from_baton(_rightBatonArea, _rightHand)
								Game.sound.play_shotgun_fire(_rightBatonArea.global_position)
							else:
								_animator.play("blaster_shoot_left")
								_gfx_muzzle_from_baton(_leftBatonArea, _leftHand)
								Game.sound.play_shotgun_fire(_leftBatonArea.global_position)
							_nextShotRight = !_nextShotRight
							var t:Transform3D = _rightBatonArea.global_transform
							_fire_projectile(t.origin, t.basis.z)
							_animator.queue("blaster_idle")
					elif Input.is_action_pressed("attack_3") && _loadedShots < _maxLoadedShots:
						start_move("reload_loop")
			################################################################
			# punch
			PlayerAttacks.Stance.Punch:
				_check_for_punch_stance_move_start(isAttacking, atkDir, _delta)
				pass
	
	var moveSpeed:float = 5.0
	#if viewLocked || Input.is_action_pressed("attack_2"):
	#	moveSpeed = 1.0
	if is_move_speed_limited():
		moveSpeed = 1.5

	#if !viewLocked && !Input.is_action_pressed("attack_2"):
	if true: # !Input.is_action_pressed("attack_2"):
		
		#if _animator.current_animation == "blaster_idle":
		#	moveSpeed = 3.0
		
		#ZqfUtils.fps_input
		
		#var pushDir:Vector3 = _calc_move_push(inputVec)
		var pushDir:Vector3 = Vector3(inputVec.x, 0, inputVec.y)
		var move:Vector3 = pushDir * moveSpeed
		self.velocity = move
		self.move_and_slide()

func _calc_move_push(inputDir:Vector2) -> Vector3:
	var inputVec:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var t:Transform3D = get_viewport().get_camera_3d().global_transform
	var flatLookTarget:Vector3 = self.global_position
	flatLookTarget.y = t.origin.y
	t = t.looking_at(flatLookTarget, Vector3.UP)
	var forward:Vector3 = t.basis.z
	
	# check we're not looking vertically down
	if forward.is_zero_approx():
		forward = t.basis.y
	var right:Vector3 = t.basis.x
	# flatten y components
	forward.y = 0.0
	right.y = 0.0
	var pushDir:Vector3 = Vector3()
	pushDir += inputVec.x * right
	pushDir += inputVec.y * forward
	return pushDir.normalized()

func _process(_delta:float) -> void:
	_groundPlane.normal = Vector3.UP
	_groundPlane.d = _aimPlanePos.global_position.y
	var mouse_pos = get_viewport().get_mouse_position()
	var camera:Camera3D = get_viewport().get_camera_3d()
	var origin = camera.project_ray_origin(mouse_pos)
	var direction = camera.project_ray_normal(mouse_pos)
	var result = _groundPlane.intersects_ray(origin, direction)
	if result == null:
		result = Vector3()
		return
	_lastAimPoint = result as Vector3
	_cursor.global_position = _lastAimPoint
	
	if !is_view_locked(): # && _timeSinceLastLookAction <= 3:
		look_at_aim_point()
	# janky - doesn't count enough actions and looks bad
	#elif _timeSinceLastLookAction > 3:
	#	look_in_move_dir()
