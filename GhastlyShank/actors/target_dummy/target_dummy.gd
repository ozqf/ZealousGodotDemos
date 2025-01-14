extends CharacterBody3D

@onready var _model:HumanoidModel = $humanoid
@onready var _hitbox:HitDelegate = $hitbox

var _tick = 1.0

func _ready() -> void:
	_model.play_idle()
	_model.attach_character_body(self, _hitbox)
	_hitbox.set_subject(_model)

func _physics_process(_delta:float) -> void:
	var tarInfo:ActorTargetInfo = Game.get_player_target()
	if !tarInfo.isValid:
		return
	var pushDir:Vector3 = Vector3()
	var flatDist:float = ZqfUtils.flat_distance_sqr(self.global_position, tarInfo.t.origin)
	
	var yawToTarget:float = ZqfUtils.yaw_between(self.global_position, tarInfo.t.origin)
	
	if flatDist < (1.5 * 1.5):
		pushDir = Vector3()
	else:
		pushDir.x = -sin(yawToTarget)
		pushDir.z = -cos(yawToTarget)
	
	_model.custom_physics_process(_delta, pushDir, yawToTarget)
	
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
