extends CharacterBody3D
class_name PlayerAvatar

const STANCE_AGILE:int = 0
const STANCE_COMBAT:int = 1

const AGILE_RUN_SPEED:float = 7.0
const COMBAT_RUNS_SPEED:float = 3.25
const EVADE_SPEED:float = 10.0
const STATIC_EVADE_TIME:float = 0.2
const STATIC_EVADE_LOCKOUT_TIME:float = 0.1
const MOVING_EVADE_TIME:float = 0.2
const MOVING_EVADE_LOCKOUT_TIME:float = 0.1

@onready var _cameraRig:CameraRig = $camera_rig
@onready var _model:HumanoidModel = $model
@onready var _targetInfo:ActorTargetInfo = $ActorTargetInfo
@onready var _hitbox:HitDelegate = $hitbox
@onready var _debugText:Label3D = $debug_text

var _stance:int = STANCE_AGILE
var _pendingStance:int = STANCE_COMBAT
var _evadeTick:float = 0.0
var _evadeLockoutTick:float = 0.0
var _evadeDir:Vector3 = Vector3()
var _attackLockoutTick:float = 0.0
var _desiredYaw:float = 0.0

var _bufferedMove:String = ""
var _bufferedMoveTick:float = 0.0

func _ready() -> void:
	self.connect("tree_exiting", _on_exiting_tree)
	_model.connect("on_hurtbox_touched_victim", _on_hurt_victim)
	_model.attach_character_body(self, _hitbox, GameController.TEAM_ID_PLAYER)
	_model.set_show_attack_indicators(false)
	_model.set_stats(HumanoidModel.WEIGHT_CLASS_PLAYER)
	_hitbox.set_subject(_model)
	Game.register_player(self)
 
func _on_exiting_tree() -> void:
	Game.register_player(null)

func _on_hurt_victim(_selfModel:HumanoidModel, _source:Area3D, _victim:Area3D) -> void:
	if _victim == _hitbox:
		# self hit
		print("Player hit self. Amateur!")
		return
	print("Player hit something. Bravo")

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

func _tick_movement_agile(pushDir:Vector3, _delta:float) -> void:
	var verticalSpeed:float = velocity.y
	velocity = pushDir * AGILE_RUN_SPEED
	if is_on_floor() && pushDir.y > 0: # jump
		velocity.y = 5.0
	else: # fall
		velocity.y = verticalSpeed + (-20.0 * _delta)
	move_and_slide()

func _tick_movement_combat(pushDir:Vector3, _delta:float) -> void:
	var verticalSpeed:float = velocity.y
	velocity = pushDir * COMBAT_RUNS_SPEED
	if is_on_floor() && pushDir.y > 0: # jump
		velocity.y = 5.0
	else: # fall
		velocity.y = verticalSpeed + (-20.0 * _delta)
	move_and_slide()

func _face_model_to_velocity() -> float:
	if velocity:
		var modelYaw:float = atan2(-velocity.x, -velocity.z)
		_desiredYaw = modelYaw
	return _desiredYaw
		#_model.set_look_yaw(modelYaw)
		#var radians:Vector3 = _model.rotation
		#radians.y = modelYaw
		#_model.rotation = radians

func _face_model_to_look() -> float:
	var dir:Vector3 = _cameraRig.get_move_basis().z
	_desiredYaw = atan2(dir.x, dir.z)
	return _desiredYaw
	#_model.set_look_yaw(_desiredYaw)

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
	if _evadeTick > 0.0:
		return false
	if !is_on_floor():
		return false
	return true

func _process(_delta: float) -> void:
	if _evadeTick > 0.0:
		_evadeTick -= _delta
	_evadeLockoutTick -= _delta
	#_model.set_blinking(_evadeTick > 0.0)
	
	if _attackLockoutTick > 0.0:
		_attackLockoutTick -= _delta

func _refresh_target_info() -> void:
	_targetInfo.isValid = true
	_targetInfo.t = self.global_transform

func _buffer_move(moveName:String) -> void:
	_bufferedMove = moveName
	_bufferedMoveTick = 0.0

func _queue_next_move(curMove:String) -> void:
	match curMove:
		HumanoidModel.ANIM_JAB:
			_buffer_move("straight")
		"straight":
			_buffer_move("hook_front")
		"hook_front":
			_buffer_move("hook_back")
		_:
			_buffer_move(HumanoidModel.ANIM_JAB)

func _physics_process(_delta: float) -> void:
	_refresh_target_info()
	_debugText.text = _model.get_debug_text()
	
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
	var input_vert:float = 0.0
	if !Zqf.has_mouse_claims():
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		input_vert = Input.get_axis("move_down", "move_up")
	var pushDir:Vector3 = (cameraBasis * Vector3(input_dir.x, input_vert, input_dir.y)).normalized()
	var canAttack:bool = _can_start_attack()
	
	# read desired move
	match _stance:
		STANCE_COMBAT:
			var v:float = Input.get_axis("move_backward", "move_forward")
			if Input.is_action_just_pressed("attack_1"):
				if v > 0:
					_buffer_move("straight")
					#_model.begin_move(HumanoidModel.ANIM_ROLLING_PUNCHES)
				elif v < 0:
					_buffer_move(HumanoidModel.ANIM_UPPERCUT)
				else:
					var curMove:String = _model.get_current_move_name()
					if curMove != "":
						_queue_next_move(curMove)
					else:
						# see if we are within a small window of a move finishing
						var lastMove:String = _model.get_last_move()
						var timeSinceLast:float = _model.get_time_since_last_move()
						if timeSinceLast > 0.25:
							_queue_next_move("")
						if timeSinceLast <= 0.25:
							_queue_next_move(lastMove)
				pass
			elif Input.is_action_just_pressed("attack_2"):
				if v > 0:
					_buffer_move(HumanoidModel.ANIM_SPIN_BACK_KICK)
				elif v < 0:
					_buffer_move(HumanoidModel.ANIM_SWEEP)
				else:
					_buffer_move(HumanoidModel.ANIM_SPIN_BACK_KICK)
			elif Input.is_action_just_pressed("attack_3"):
				if v < 0:
					_buffer_move("taunt_bring_it_on")
				else:
					_buffer_move("haymaker_loop")

	if _bufferedMove != "":
		_bufferedMoveTick += _delta
		if _bufferedMoveTick > 0.35:
			_buffer_move("")

	match _stance:
		STANCE_COMBAT:
			
			if _evadeTick > 0.0:
				velocity = _evadeDir * EVADE_SPEED
				move_and_slide()
				return
			# always favour evade over starting a move
			if Input.is_action_just_pressed("move_special"):
				# player is trying to evade, lets clear their move buffer
				_buffer_move("")
				if _model.begin_evade(pushDir):
					canAttack = false
			
			var startedMove:bool = false
			if canAttack && _bufferedMove != "":
				var startMove:String = _bufferedMove
				_bufferedMove = ""
				_face_model_to_look()
				_model.set_look_yaw(_desiredYaw)
				_model.begin_move(startMove)

			if !pushDir.is_zero_approx():
				_face_model_to_look()
			_model.custom_physics_process(_delta, pushDir, _desiredYaw)
			#if !startedMove && canAttack:
			#	_tick_movement_combat(pushDir, _delta)
			#	_face_model_to_look()
			#else:
			#	_tick_movement_combat(Vector3(), _delta)
		_:
			_tick_movement_agile(pushDir, _delta)
			if Input.is_action_just_pressed("attack_1") && _can_start_attack():
				_model.begin_agile_whirlwind()
			_face_model_to_velocity()
			_model.set_look_yaw(_desiredYaw)
