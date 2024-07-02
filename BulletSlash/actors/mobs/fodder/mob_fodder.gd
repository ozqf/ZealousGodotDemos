extends MobBase

const MOB_STATE_IDLE:String = "idle"
const MOB_STATE_STUNNED:String = "stunned"
const MOB_STATE_CHASE:String = "chase"

const ANIM_IDLE:String = "_idle"
const ANIM_SWING_1:String = "swing_1"

@onready var _animator:AnimationPlayer = $display/AnimationPlayer
@onready var _weapon:Area3D = $display/right_hand/melee_weapon
var _hitInfo:HitInfo = null

var _state:String = MOB_STATE_IDLE
var _thinkTick:float = 0.0
var _thinkTime:float = 0.5

func _ready() -> void:
	super._ready()
	_bodyDisplayRoot = get_node_or_null("display/placehold_mob_model")
	_hitInfo = Game.new_hit_info()
	_hitInfo.damageTeamId = Game.TEAM_ID_ENEMY
	_hitInfo.sourceTeamId = Game.TEAM_ID_ENEMY
	_animator.connect("animation_event", _animation_event)
	_weapon.connect("area_entered", _on_weapon_touched_area)

func _animation_event(eventType:String) -> void:
	#print("Saw anim event type " + str(eventType))
	match eventType:
		AnimationEmitter.EVENT_RIGHT_WEAPON_ON:
			_weapon.monitorable = true
			_weapon.monitoring = true
		AnimationEmitter.EVENT_RIGHT_WEAPON_OFF:
			_weapon.monitorable = false
			_weapon.monitoring = false

func _on_weapon_touched_area(area:Area3D) -> void:
	var result:int = Game.try_hit(_hitInfo, area)
	print("Mob response " + str(result))

func _change_state(newState:String) -> void:
	if _state == newState:
		return
	_state = newState
	match _state:
		MOB_STATE_STUNNED:
			_animator.play("stunned")
	_thinkTick = 0.0

func spawn() -> void:
	super.spawn()
	_health = 10.0
	_hitBounceTime = 1.0

func hit(_incomingHit:HitInfo) -> int:
	var result:int = super.hit(_incomingHit)
	if _health <= 0.0:
		self.queue_free()
		return 1
	if result > 0:
		_change_state(MOB_STATE_STUNNED)
		_thinkTime = _hitBounceTime
	return result

func _think() -> void:
	match _state:
		MOB_STATE_STUNNED:
			_animator.play("_idle")
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
			var distSqr:float = _thinkInfo.xzTowardTarget.length_squared()
			var runDist:float = 7.0
			var stopDist:float = 2.0
			if distSqr > (runDist * runDist):
				_step_toward_flat(tarPos, 8.0, _delta)
			elif distSqr > (stopDist * stopDist):
				_step_toward_flat(tarPos, 2.0, _delta)
			else:
				_animator.play(ANIM_SWING_1)

func _process(delta) -> void:
	super._process(delta)
