extends CharacterBody3D
class_name PlayerAvatar

const STANCE_AGILE:int = 0
const STANCE_COMBAT:int = 1

const AGILE_RUN_SPEED:float = 8.0
const COMBAT_RUNS_SPEED:float = 4.0
const EVADE_SPEED:float = 9.0

@onready var _cameraRig:CameraRig = $camera_rig
@onready var _model:PlayerModel = $player_model
@onready var _targetInfo:ActorTargetInfo = $ActorTargetInfo

var _stance:int = STANCE_COMBAT
var _pendingStance:int = STANCE_AGILE
var _evadeTick:float = 0.0
var _evadeLockoutTick:float = 0.0
var _evadeDir:Vector3 = Vector3()
var _attackLockoutTick:float = 0.0

func _ready() -> void:
	self.connect("tree_exiting", _on_exiting_tree)
	Game.register_player(self)

func _on_exiting_tree() -> void:
	Game.register_player(null)

func _tick_movement(_delta:float) -> void:
	var cameraBasis:Basis = _cameraRig.get_move_basis()
	
	var input_dir:Vector2 = Vector2()
	if !Zqf.has_mouse_claims():
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var pushDir:Vector3 = (cameraBasis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity = pushDir * 5
	
	if velocity:
		var modelYaw:float = atan2(-velocity.x, -velocity.z)
		var radians:Vector3 = _model.rotation
		radians.y = modelYaw
		_model.rotation = radians		

	move_and_slide()

func get_target_info() -> ActorTargetInfo:
	return _targetInfo

func _tick_movement_agile(pushDir:Vector3) -> void:
	velocity = pushDir * AGILE_RUN_SPEED
	move_and_slide()

func _tick_movement_combat(pushDir:Vector3) -> void:
	velocity = pushDir * COMBAT_RUNS_SPEED
	move_and_slide()

func _face_model_to_velocity() -> void:
	if velocity:
		var modelYaw:float = atan2(-velocity.x, -velocity.z)
		_model.set_look_yaw(modelYaw)
		#var radians:Vector3 = _model.rotation
		#radians.y = modelYaw
		#_model.rotation = radians

func _face_model_to_look() -> void:
	var dir:Vector3 = _cameraRig.get_move_basis().z
	var modelYaw:float = atan2(dir.x, dir.z)
	_model.set_look_yaw(modelYaw)
	#var radians:Vector3 = _model.rotation
	#radians.y = modelYaw
	#_model.rotation = radians

func _can_change_stance() -> bool:
	if _model.is_performing_move():
		return false
	return true

func _can_start_attack() -> bool:
	if _attackLockoutTick > 0.0:
		return false
	if _model.is_performing_move():
		return false
	if _evadeTick > 0.0:
		return false
	if !is_on_floor():
		return false
	return true

func _can_evade() -> bool:
	if _evadeLockoutTick > 0.0:
		return false
	return _can_start_attack()

func _process(_delta: float) -> void:
	if _evadeTick > 0.0:
		_evadeTick -= _delta
	_evadeLockoutTick -= _delta
	_model.set_blinking(_evadeTick > 0.0)
	if _attackLockoutTick > 0.0:
		_attackLockoutTick -= _delta

func _refresh_target_info() -> void:
	_targetInfo.isValid = true
	_targetInfo.t = self.global_transform

func _physics_process(_delta: float) -> void:
	_refresh_target_info()
	
	if Input.is_action_just_pressed("slot_1"):
		_pendingStance = STANCE_AGILE
	if Input.is_action_just_pressed("slot_2"):
		_pendingStance = STANCE_COMBAT
	
	if _pendingStance != _stance && _can_change_stance():
		_stance = _pendingStance
		match _stance:
			STANCE_COMBAT:
				_model.set_idle_to_combat()
			_:
				_model.set_idle_to_agile()
		_model.play_idle()

	var cameraBasis:Basis = _cameraRig.get_move_basis()
	var input_dir:Vector2 = Vector2()
	if !Zqf.has_mouse_claims():
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var pushDir:Vector3 = (cameraBasis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var canAttack:bool = _can_start_attack()

	match _stance:
		STANCE_COMBAT:
			
			if _evadeTick > 0.0:
				velocity = _evadeDir * EVADE_SPEED
				move_and_slide()
				return
			# always favour evade over starting a move
			if _can_evade() && Input.is_action_just_pressed("move_special"):
				_model.set_blinking(true)
				if pushDir.is_zero_approx():
					# static evade
					_evadeTick = 0.2
					_evadeLockoutTick = 0.3
					_evadeDir = Vector3()
				else:
					_evadeTick = 0.3
					_evadeLockoutTick = 0.4
					_evadeDir = pushDir
				canAttack = false
			
			var startedMove:bool = false
			if canAttack:
				var v:float = Input.get_axis("move_backward", "move_forward")
				if Input.is_action_just_pressed("attack_1"):
					if v > 0:
						_model.begin_thrust()
					elif v < 0:
						_model.begin_uppercut()
					else:
						_model.begin_horizontal_swing()
				elif Input.is_action_just_pressed("attack_2"):
					pass
					#_model.begin_thrust()
			
			if !startedMove && canAttack:
				_tick_movement_combat(pushDir)
				_face_model_to_look()
		_:
			_tick_movement_agile(pushDir)
			if Input.is_action_just_pressed("attack_1") && _can_start_attack():
				_model.begin_agile_whirlwind()
			_face_model_to_velocity()
