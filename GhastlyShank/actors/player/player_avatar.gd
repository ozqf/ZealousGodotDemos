extends CharacterBody3D
class_name PlayerAvatar

const STANCE_AGILE:int = 0
const STANCE_COMBAT:int = 1

const AGILE_RUN_SPEED:float = 7.0
const COMBAT_RUNS_SPEED:float = 3.25

@onready var _cameraRig:CameraRig = $camera_rig
@onready var _model:HumanoidModel = $model
@onready var _targetInfo:ActorTargetInfo = $ActorTargetInfo
@onready var _hitbox:HitDelegate = $hitbox
@onready var _debugText:Label3D = $debug_text

var _evadeTick:float = 0.0
var _desiredYaw:float = 0.0

func _ready() -> void:
	self.connect("tree_exiting", _on_exiting_tree)
	_model.connect("on_hurtbox_touched_victim", _on_hurt_victim)
	_model.attach_character_body(self, _hitbox, GameController.TEAM_ID_PLAYER)
	#_model.set_show_attack_indicators(false)
	_model.set_stats(Mobs.WEIGHT_CLASS_PLAYER)
	_hitbox.set_subject(_model)
	Game.register_player(self)
	_debugText.visible = false

func _on_exiting_tree() -> void:
	Game.register_player(null)

func _on_hurt_victim(_selfModel:HumanoidModel, _source:Area3D, _victim:Area3D) -> void:
	if _victim == _hitbox:
		# self hit
		print("Player hit self. Amateur!")
		return
	print("Player hit something. Bravo")

func get_target_info() -> ActorTargetInfo:
	return _targetInfo

func get_actor_category() -> int:
	return Interactions.ACTOR_CATEGORY_PLAYER_AVATAR

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
	if _model.is_performing_move():
		return false
	if _evadeTick > 0.0:
		return false
	if !is_on_floor():
		return false
	return true

func _refresh_target_info() -> void:
	_targetInfo.isValid = true
	_targetInfo.t = self.global_transform

func _queue_next_move(curMove:String) -> void:
	match curMove:
		HumanoidModel.MOVE_JAB:
			_model.buffer_move("straight")
		"straight":
			_model.buffer_move("hook_front")
		"hook_front":
			_model.buffer_move("hook_back")
		_:
			_model.buffer_move(HumanoidModel.MOVE_JAB)

func _physics_process(_delta: float) -> void:
	_refresh_target_info()
	var txt = _model.get_debug_text()
	_debugText.text = txt
	
	if Input.is_action_just_pressed("slot_1"):
		_model.set_desired_stance(HumanoidModel.STANCE_AGILE)
	if Input.is_action_just_pressed("slot_2"):
		_model.set_desired_stance(HumanoidModel.STANCE_COMBAT)
	var stance:int = _model.check_stance()

	var cameraBasis:Basis = _cameraRig.get_move_basis()
	var input_dir:Vector2 = Vector2()
	var input_vert:float = 0.0
	if !Zqf.has_mouse_claims():
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		input_vert = Input.get_axis("move_down", "move_up")
	var pushDir:Vector3 = (cameraBasis * Vector3(input_dir.x, input_vert, input_dir.y)).normalized()
	
	var atk1:bool = false
	var atk2:bool = false
	var atk3:bool = false
	var moveSpecial:bool = false
	if !Zqf.has_mouse_claims():
		atk1 = Input.is_action_just_pressed("attack_1")
		atk2 = Input.is_action_just_pressed("attack_2")
		atk3 = Input.is_action_just_pressed("attack_3")
		moveSpecial = Input.is_action_just_pressed("move_special")
	
	var buttons:int = 0
	if Input.is_action_pressed("attack_1"):
		buttons |= HumanoidModel.ATK_HOLD_BIT_0
	if Input.is_action_pressed("attack_2"):
		buttons |= HumanoidModel.ATK_HOLD_BIT_1
	if Input.is_action_pressed("attack_3"):
		buttons |= HumanoidModel.ATK_HOLD_BIT_2

	if _model.get_state() == Mobs.STATE_PERFORMING_CHARGE_MOVE:

		pass
	
	# read desired move
	match stance:
		HumanoidModel.STANCE_COMBAT:
			var v:float = Input.get_axis("move_backward", "move_forward")
			if !self.is_on_floor():
				if atk2:
					_model.buffer_move("air_split_kicks")
					#_model.buffer_move("air_snap_kicks")
			else:
				if atk1:
					if v > 0:
						_model.buffer_move("straight")
					elif v < 0:
						_model.buffer_move(HumanoidModel.MOVE_UPPERCUT, 1.0, HumanoidModel.ATK_HOLD_BIT_0)
					else:
						var curMove:String = _model.get_current_move_name()
						if curMove != "":
							_queue_next_move(curMove)
						else:
							# see if we are within a small window of a move finishing
							var lastMove:String = _model.get_last_move()
							var timeSinceLast:float = _model.get_time_since_last_move()
							if timeSinceLast > 0.3:
								_queue_next_move("")
							if timeSinceLast <= 0.3:
								_queue_next_move(lastMove)
					pass
				elif atk2:
					if v > 0:
						_model.buffer_move("no_shadow_kick_charge", 1.0, HumanoidModel.ATK_HOLD_BIT_1)
					elif v < 0:
						_model.buffer_move(HumanoidModel.MOVE_SWEEP)
					else:
						_model.buffer_move(HumanoidModel.MOVE_SPIN_BACK_KICK)
				elif atk3:
					if v < 0:
						_model.buffer_move("taunt_bring_it_on")
					else:
						_model.buffer_move("haymaker_loop")
		HumanoidModel.STANCE_AGILE:
			#var v:float = Input.get_axis("move_backward", "move_forward")
			if !self.is_on_floor():
				if atk2:
					_model.buffer_move("flying_kick")
			else:
				if atk2:
					_model.buffer_move("slide_kick")

	match stance:
		HumanoidModel.STANCE_COMBAT:
			# always favour evade over starting a move
			if moveSpecial:
				# player is trying to evade, lets clear their move buffer
				_model.buffer_move("")
				_model.begin_evade(pushDir)
			
			if !pushDir.is_zero_approx():
				_face_model_to_look()
			_model.custom_physics_process(_delta, pushDir, _desiredYaw, buttons)
		_:
			_model.custom_physics_process(_delta, pushDir, _desiredYaw, buttons)
