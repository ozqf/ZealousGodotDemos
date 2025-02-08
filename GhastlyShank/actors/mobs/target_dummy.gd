extends CharacterBody3D

const MELEE_RANGE:float = 1.6

@export var uuid:String = ""
@onready var _model:HumanoidModel = $humanoid
@onready var _hitbox:HitDelegate = $hitbox

var _tick = 1.0
var _speedMul:float = 0.5

func _ready() -> void:
	if (uuid == ""):
		uuid = UUID.v4()
	_model.play_idle()
	_model.attach_character_body(self, _hitbox, GameController.TEAM_ID_ENEMY)
	_hitbox.set_subject(_model)

func _start_random_move() -> void:
	var r:float = randf()
	if r > 0.75:
		_model.buffer_move("sweep", _speedMul)
	elif r > 0.5:
		_model.buffer_move("hook_back", _speedMul)
	elif r > 0.25:
		_model.buffer_move("spin_back_kick",_speedMul)
	else:
		_model.buffer_move("jab_slow")

func _physics_process(_delta:float) -> void:
	var tarInfo:ActorTargetInfo = Game.get_player_target()
	if !tarInfo.isValid:
		_model.custom_physics_process(_delta, Vector3(), 0, 0)
		return
	
	var pushDir:Vector3 = Vector3()
	var flatDist:float = ZqfUtils.flat_distance_sqr(self.global_position, tarInfo.t.origin)

	var desiredStance:int = HumanoidModel.STANCE_COMBAT
	if flatDist > 15.0:
		desiredStance = HumanoidModel.STANCE_AGILE
	_model.set_desired_stance(desiredStance)
	_model.check_stance()
	
	var yawToTarget:float = ZqfUtils.yaw_between(self.global_position, tarInfo.t.origin)

	if flatDist < (MELEE_RANGE * MELEE_RANGE):
		pushDir = Vector3()
		#_model.begin_move("spin_back_kick", _speedMul)
		#_start_random_move()
		_model.buffer_move("sweep", _speedMul)
		#_model.set_look_yaw(yawToTarget)
	else:
		pushDir.x = -sin(yawToTarget)
		pushDir.z = -cos(yawToTarget)
	
	_model.custom_physics_process(_delta, pushDir, yawToTarget, 0)
	
	#if !_model.is_performing_move() && flatDist < (2 * 2):
	#	_tick -= _delta
	#	if _tick <= 0.0:
	#		_tick = randf_range(1.0, 3.0)
	#		var r:float = randf()
	#		if r > 0.6:
	#			_model.begin_move("uppercut_slow")
	#		elif r > 0.3:
	#			_model.begin_sweep(0.5)
	#		else:
	#			_model.begin_move("jab_slow")
	#	else:
	#		_model.look_at_flat(tarInfo.t.origin)
	#pass
