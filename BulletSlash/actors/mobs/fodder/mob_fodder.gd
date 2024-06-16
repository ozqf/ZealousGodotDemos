extends MobBase

const MOB_STATE_IDLE:String = "idle"
const MOB_STATE_STUNNED:String = "stunned"
const MOB_STATE_CHASE:String = "chase"

var _state:String = MOB_STATE_IDLE
var _thinkTick:float = 0.0
var _thinkTime:float = 0.5

func _change_state(newState:String) -> void:
	if _state == newState:
		return
	_state = newState
	_thinkTick = 0.0

func hit(_hitInfo) -> int:
	var result:int = super.hit(_hitInfo)
	if result > 0:
		_change_state(MOB_STATE_STUNNED)
		_thinkTime = HIT_BOUNCE_TIME
	return result

func _think() -> void:
	match _state:
		MOB_STATE_STUNNED:
			_thinkTime = 0.2
			_change_state(MOB_STATE_CHASE)
			pass
		_:
			var plyr:TargetInfo = Game.get_player_target()
			if plyr != null:
				_change_state(MOB_STATE_CHASE)

func _physics_process(_delta:float) -> void:
	_refresh_think_info(_delta)
	_thinkTick += _delta
	if _thinkTick >= _thinkTime:
		_thinkTick = 0.0
		_think()
	match _state:
		MOB_STATE_CHASE:
			if _thinkInfo.target == null:
				_change_state(MOB_STATE_IDLE)
				return
			var tarPos:Vector3 = _thinkInfo.target.t.origin
			_look_toward_flat(tarPos)
			_step_toward_flat(tarPos, _delta)
			pass

func _process(delta) -> void:
	super._process(delta)
