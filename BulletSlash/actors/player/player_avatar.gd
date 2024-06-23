extends CharacterBody3D
class_name PlayerAvatar

@onready var _cursor:Node3D = $cursor
@onready var _aimPlanePos:Node3D = $aim_plane_pos
@onready var _display:Node3D = $display
@onready var _animator:AnimationPlayer = $display/AnimationPlayer
@onready var _rightBatonArea:Area3D = $display/right_hand/right_baton/hitbox
@onready var _leftBatonArea:Area3D = $display/left_hand/left_baton/hitbox
@onready var _hudInfo:HudInfo = $HudInfo
var _groundPlane:Plane = Plane()

enum AttackInputDir { Neutral, Forward, Backward }

var _stance:PlayerAttacks.Stance = PlayerAttacks.Stance.Punch
var _pendingStance:PlayerAttacks.Stance = PlayerAttacks.Stance.Blade
var _inMoveRecovery:bool = false

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

var _tryAttackSequenceTick:float = 0.0

var _moves:Dictionary
var _lastMove:Dictionary = {}
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
	_targetInfo = Game.new_target_info()
	_return_to_idle_animation()
	_animator.connect("current_animation_changed", _on_weapon_animation_changed)
	_rightBatonArea.connect("area_entered", _on_area_entered_right_baton)
	_leftBatonArea.connect("area_entered", _on_area_entered_left_baton)
	var grp = Game.GROUP_GAME_EVENTS
	var fn = Game.GAME_EVENT_FN_PLAYER_SPAWNED
	get_tree().call_group(grp, fn, self)

##########################################################################
# Do hits
##########################################################################
func _hit_target(target:Area3D, weaponArea:Area3D) -> void:
	_hitInfo.position = weaponArea.global_position
	if !_lastMove.is_empty() && _lastMove.damageType == GameMain.DAMAGE_TYPE_SLASH:
		# "...and the blood will go fftsssssssssssh..."
		_hitInfo.direction = -weaponArea.global_transform.basis.x
	else:
		_hitInfo.direction = weaponArea.global_transform.basis.z
	var result:int = Game.try_hit(_hitInfo, target)

func _on_area_entered_right_baton(_area:Area3D) -> void:
	_hit_target(_area, _rightBatonArea)

func _on_area_entered_left_baton(_area:Area3D) -> void:
	_hit_target(_area, _leftBatonArea)

func _set_area_on(area:Area3D, flag:bool) -> void:
	area.monitoring = flag
	area.monitorable = flag

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
	_lastMove = candidateMove
	var numAnimations:int = candidateMove.animations.size()
	if numAnimations == 0:
		return
	
	_animator.play(candidateMove.animations[0])
	for i in range (1, numAnimations):
		_animator.queue(candidateMove.animations[i])
	
	# apply
	_lastMove = candidateMove
	_attack1Buffered = false
	_attack2Buffered = false
	_inMoveRecovery = false
	
	#_animator.play(_lastMove.animation)
	_animator.queue(_lastMove.idleAnimation)
	_hitInfo.damageType = _lastMove.damageType

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
	if !consume_shot_for_loop(_lastMove[PlayerAttacks.FIELD_SHOTS_CONSUMED_ON_LOOP]):
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
	if !_load_shot():
		return
	var pos:Vector3 = _rightBatonArea.global_position
	var dir:Vector3 = -_rightBatonArea.global_transform.basis.x
	Game.spawn_gfx_ejected_shell(pos, dir)

func load_shot_from_left_spin() -> void:
	if !_load_shot():
		return
	var pos:Vector3 = _leftBatonArea.global_position
	var dir:Vector3 = -_leftBatonArea.global_transform.basis.x
	Game.spawn_gfx_ejected_shell(pos, dir)

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

##########################################################################
# attacks
##########################################################################
func look_at_aim_point() -> void:
	var displayPos:Vector3 = _display.global_position
	displayPos.y = _lastAimPoint.y
	_display.look_at(_lastAimPoint, Vector3.UP)

func is_view_locked() -> bool:
	match _animator.current_animation:
		"", "punch_idle", "blaster_idle", "blade_idle", "blaster_shoot_left", "blaster_shoot_right", "punch_dash", "blaster_reload":
			return false
		"punch_charge_stance":
			return false
		null:
			return false
		_:
			return true

func is_move_speed_limited() -> bool:
	match _animator.current_animation:
		"", "punch_idle", "blaster_idle", "blade_idle", "blaster_shoot_left", "blaster_shoot_right", "punch_dash":
			return false
		_:
			return true

func _step_dash(_delta:float) -> void:
	var move:Vector3 = Vector3(_dashInput.x, 0, _dashInput.y) * 10.0
	self.velocity = move
	self.move_and_slide()

func _fire_projectile() -> void:
	var prj:PrjBasic = Game.spawn_prj_basic()
	var info:ProjectileLaunchInfo = prj.get_launch_info()
	info.origin = _rightBatonArea.global_position
	info.forward = -_display.global_transform.basis.z
	prj.launch()
	_refireTick = 0.2

func _get_attack_dir(inputVec:Vector2) -> AttackInputDir:
	var inputDir:Vector3 = Vector3(inputVec.x, 0, inputVec.y)
	var dot:float = inputDir.dot(-_display.global_transform.basis.z)
	if dot > 0.0:
		return AttackInputDir.Forward
	elif dot < 0.0:
		return AttackInputDir.Backward
	return AttackInputDir.Neutral

func _check_for_blade_stance_move_start(isAttacking:bool, atkDir:AttackInputDir, _delta:float) -> void:
	if isAttacking:
		return
	var atkOneJustOn:bool = Input.is_action_just_pressed("attack_1")
	var atkTwoOn:bool = Input.is_action_pressed("attack_2")
	var atkThree:bool = Input.is_action_pressed("attack_3")

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
			start_move("double_spin")
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
			start_move("punch_machine_gun")
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
		
		if _tryAttackSequenceTick > 0.0 && !_lastMove.is_empty() && _lastMove.name == "punch_jab_left":
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

func _gfx_muzzle_from_baton(baton:Area3D) -> void:
	var t:Transform3D = baton.global_transform
	# batons are technically facing backwards so NOT -basis.z
	Game.spawn_gfx_blaster_muzzle(t.origin, t.basis.z)

func gfx_muzzle_from_right_baton() -> void:
	_gfx_muzzle_from_baton(_rightBatonArea)

func gfx_muzzle_from_left_baton() -> void:
	_gfx_muzzle_from_baton(_leftBatonArea)

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
	_tryAttackSequenceTick -= _delta
	_refireTick -= _delta
	refresh_target_info()
	_broadcast_hud_info()

	# inputs
	if Input.is_action_just_pressed("slot_1"):
		_pendingStance = PlayerAttacks.Stance.Blade
	elif Input.is_action_just_pressed("slot_2"):
		_pendingStance = PlayerAttacks.Stance.Gun
	elif Input.is_action_just_pressed("slot_3"):
		_pendingStance = PlayerAttacks.Stance.Punch
	
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
	
	var isAttacking:bool = viewLocked
	
	if !isAttacking:
		if Input.is_action_pressed("attack_2"):
			_animator.play("punch_charge_stance")
		elif _animator.current_animation == "punch_charge_stance":
			if _stance == PlayerAttacks.Stance.Punch:
				_animator.play("punch_idle")
			else:
				_animator.play("blade_idle")

	if isAttacking:
		if Input.is_action_just_pressed("attack_1"):
			_attack1Buffered = true
		elif Input.is_action_just_pressed("attack_2"):
			_attack2Buffered = true
	
	match _stance:
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
							_gfx_muzzle_from_baton(_rightBatonArea)
						else:
							_animator.play("blaster_shoot_left")
							_gfx_muzzle_from_baton(_leftBatonArea)
						_nextShotRight = !_nextShotRight
						_fire_projectile()
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
		moveSpeed = 1.0

	#if !viewLocked && !Input.is_action_pressed("attack_2"):
	if true: # !Input.is_action_pressed("attack_2"):
		
		#if _animator.current_animation == "blaster_idle":
		#	moveSpeed = 3.0
		var move:Vector3 = Vector3(inputVec.x, 0, inputVec.y) * moveSpeed
		self.velocity = move
		self.move_and_slide()

func _process(_delta:float) -> void:
	_groundPlane.normal = Vector3.UP
	_groundPlane.d = _aimPlanePos.global_position.y
	var mouse_pos = get_viewport().get_mouse_position()
	var camera:Camera3D = get_viewport().get_camera_3d()
	var origin = camera.project_ray_origin(mouse_pos)
	var direction = camera.project_ray_normal(mouse_pos)
	_lastAimPoint = _groundPlane.intersects_ray(origin, direction)
	_cursor.global_position = _lastAimPoint
	
	if !is_view_locked():
		look_at_aim_point()
