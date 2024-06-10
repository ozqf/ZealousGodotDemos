extends CharacterBody3D
class_name PlayerAvatar

@onready var _cursor:Node3D = $cursor
@onready var _aimPlanePos:Node3D = $aim_plane_pos
@onready var _display:Node3D = $display
@onready var _animator:AnimationPlayer = $display/AnimationPlayer
@onready var _rightBatonArea:Area3D = $display/right_hand/right_baton/hitbox
@onready var _leftBatonArea:Area3D = $display/left_hand/left_baton/hitbox
var _groundPlane:Plane = Plane()

enum AttackInputDir { Neutral, Forward, Backward }

var _targetInfo:TargetInfo
var _lastAimPoint:Vector3 = Vector3()
var _animationRepeatPosition:float = 0.0
var _nextShotRight:bool = true

var _hitInfo:HitInfo

var _dashInput:Vector2 = Vector2()

var _refireTick:float = 0.0

func _ready() -> void:
	_hitInfo = Game.new_hit_info()
	_targetInfo = Game.new_target_info()
	_animator.play("punch_idle")
	_rightBatonArea.connect("area_entered", _on_area_entered_right_baton)
	_leftBatonArea.connect("area_entered", _on_area_entered_left_baton)
	var grp = Game.GROUP_GAME_EVENTS
	var fn = Game.GAME_EVENT_FN_PLAYER_SPAWNED
	get_tree().call_group(grp, fn, self)

func _on_area_entered_right_baton(_area:Area3D) -> void:
	_hitInfo.position = _rightBatonArea.global_position
	if _animator.current_animation == "double_spin_chain":
		_hitInfo.direction = -_rightBatonArea.global_transform.basis.x
	else:
		_hitInfo.direction = _rightBatonArea.global_transform.basis.z
	var result:int = Game.try_hit(_hitInfo, _area)
	var gfx = Game.spawn_gfx_blade_blood_spurt(_area.global_position, _hitInfo.direction)
	print("Right baton hit result " + str(result))

func _on_area_entered_left_baton(_area:Area3D) -> void:
	_hitInfo.position = _leftBatonArea.global_position
	if _animator.current_animation == "double_spin_chain":
		_hitInfo.direction = -_leftBatonArea.global_transform.basis.x
	else:
		_hitInfo.direction = _leftBatonArea.global_transform.basis.z
	var result:int = Game.try_hit(_hitInfo, _area)
	var gfxDir:Vector3 = _hitInfo.direction
	gfxDir.y = 0
	gfxDir = gfxDir.normalized()
	var gfx = Game.spawn_gfx_blade_blood_spurt(_area.global_position, gfxDir)
	print("Left baton hit " + str(result))
	
func _set_area_on(area:Area3D, flag:bool) -> void:
	area.monitoring = flag
	area.monitorable = flag

func check_attack_chain_cancel() -> void:
	if !Input.is_action_pressed("attack_3"):
		_animator.clear_queue()
		_animator.play("punch_idle")
	else:
		look_at_aim_point()

func check_animation_loop() -> void:
	if !Input.is_action_pressed("attack_3"):
		return
	match _animator.current_animation:
		"punch_spin_test":
			_animator.seek(0.2)
		"double_spin_chain":
			#print("Repeat from " + str(_animationRepeatPosition))
			_animator.seek(_animationRepeatPosition, true, true)
		_:
			_animator.seek(_animationRepeatPosition, true, true)

func mark_repeat_time() -> void:
	_animationRepeatPosition = _animator.current_animation_position
	#print("Mark repeat " + str(_animationRepeatPosition))

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

func _exit_tree():
	var grp = Game.GROUP_GAME_EVENTS
	var fn = Game.GAME_EVENT_FN_PLAYER_DESPAWNED
	get_tree().call_group(grp, fn, self)

func look_at_aim_point() -> void:
	var displayPos:Vector3 = _display.global_position
	displayPos.y = _lastAimPoint.y
	_display.look_at(_lastAimPoint, Vector3.UP)

func is_view_locked() -> bool:
	match _animator.current_animation:
		"punch_idle":
			return false
		"blaster_idle":
			return false
		"":
			return false
		"punch_dash":
			return false
		null:
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

func _get_attack_dir(inputVec:Vector2) -> AttackInputDir:
	var inputDir:Vector3 = Vector3(inputVec.x, 0, inputVec.y)
	var dot:float = inputDir.dot(-_display.global_transform.basis.z)
	if dot > 0.0:
		return AttackInputDir.Forward
	elif dot < 0.0:
		return AttackInputDir.Backward
	return AttackInputDir.Neutral

func _physics_process(_delta:float) -> void:
	var viewLocked:bool = is_view_locked()
	var inputVec:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var atkDir:AttackInputDir = _get_attack_dir(inputVec)
	if _animator.current_animation == "punch_dash":
		_step_dash(_delta)
		return
		
	if Input.is_action_just_pressed("dash") && !viewLocked:
		_dashInput = inputVec
		_animator.play("punch_dash")
		_animator.queue("punch_idle")
		_step_dash(_delta)
		return
	
	var isAttacking:bool = viewLocked
	
	if !isAttacking && Input.is_action_just_pressed("attack_1"):
		look_at_aim_point()
		_animator.play("punch_jab_left")
		_animator.queue("punch_idle")
	
	if !isAttacking && Input.is_action_just_pressed("attack_2"):
		if _nextShotRight:
			_animator.play("blaster_shoot_right")
		else:
			_animator.play("blaster_shoot_left")
		_nextShotRight = !_nextShotRight
		_fire_projectile()
		_animator.queue("blaster_idle")
	
	if !isAttacking && Input.is_action_just_pressed("attack_3"):
		look_at_aim_point()
		match atkDir:
			AttackInputDir.Backward:
				look_at_aim_point()
				_animator.play("shredder")
				_animator.queue("punch_idle")
			_:
				look_at_aim_point()
				_animator.play("double_spin_chain")
				_animator.queue("punch_idle")
		
	
	if !viewLocked:
		var moveSpeed:float = 5.0
		if _animator.current_animation == "blaster_idle":
			moveSpeed = 3.0
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
