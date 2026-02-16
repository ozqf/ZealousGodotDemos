extends MobModel

@onready var _debug:Label3D = $Label3D
@onready var _animTree:AnimationTree = $AnimationTree
@onready var _anims:AnimationPlayer = $AnimationPlayer
@onready var _rightMuzzleFlash:ZqfTimedVisible = $body/right_hand/flash

var isShooting:bool = false

var _tick:float = 1.0
var _loops:int = 0
var _animState:AnimationNodeStateMachinePlayback
var _lastStateNode:String = ""

var _lastAnimFinishSeen:String = ""
var _lastAnimFinishProcessed:String = ""

var _painTick:float = 3.0
var _painBlend:float = 0.0

func _ready() -> void:
	_animTree.active = true
	_animState = _animTree.get("parameters/AnimationNodeStateMachine/playback") as AnimationNodeStateMachinePlayback
	#_lastStateNode = _animState.get_current_node()
	_animTree.connect("animation_finished", _on_anim_finished)

func _on_anim_finished(anim_name:String) -> void:
	if anim_name == "":
		print("Saw empty anim finish")
	if anim_name == "pain":
		print("Ignored pain anim finish")
		return
	print("Tree anim finished " + str(anim_name))
	_lastAnimFinishSeen = anim_name

func hit_flinch(weight:float = 0.5) -> void:
	weight = clampf(weight, 0.1, 0.9)
	_painBlend = weight

func muzzle_flash(_index:int = 0) -> void:
	_rightMuzzleFlash.start(0.1)

func aim_weapon(_index:int = 0, windUpTime:float = 1.0) -> void:
	var root:String = "parameters/AnimationNodeStateMachine/conditions/"
	_animTree.set(root + "is_aiming_right", true)
	_animTree.set(root + "is_shooting_right", false)
	_animTree.set(root + "is_winding_down", false)
	
	var path:String = "parameters/AnimationNodeStateMachine/fire_right_enter/enter_aim_ts/scale"
	#var windUpTime:float = 0.25
	var ts:float = 1.0 / windUpTime
	_animTree.set(path, ts)

func is_aiming(_index:int = 0) -> bool:
	var curNode:String = _animState.get_current_node()
	var isAiming:bool = curNode == "fire_right_aim"
	return isAiming

func end_aim_weapon() -> void:
	var root:String = "parameters/AnimationNodeStateMachine/conditions/"
	_animTree.set(root + "is_aiming_right", false)
	_animTree.set(root + "is_shooting_right", false)
	_animTree.set(root + "is_winding_down", true)

func die() -> void:
	_animState.travel("dazed")

func _start_shooting_right() -> void:
	var root:String = "parameters/AnimationNodeStateMachine/conditions/"
	_animTree.set(root + "is_aiming_right", true)
	_animTree.set(root + "is_shooting_right", true)
	_animTree.set(root + "is_winding_down", false)

func _end_shooting_right() -> void:
	var root:String = "parameters/AnimationNodeStateMachine/conditions/"
	_animTree.set(root + "is_aiming_right", false)
	_animTree.set(root + "is_shooting_right", false)
	_animTree.set(root + "is_winding_down", true)

func _run_pain(_delta:float) -> void:
	if _painBlend > 0.0:
		var path:String = "parameters/pain_blend/blend_amount"
		_animTree.set(path, _painBlend)
	_painTick -= _delta
	_painBlend = clampf(_painBlend - (_delta * 4), 0.0, 0.99)
	if _painTick > 0.0:
		return
	#_painTick = randf_range(2, 4)
	#_painBlend = 1.0
	#print("Pain - next in " + str(_painTick))
	
	#var path:String = "parameters/pain_one_shot/request"
	#_animTree.set(path, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	pass

func _physics_process(delta: float) -> void:
	_run_pain(delta)

func _physics_process_test_loop(_delta: float) -> void:
	_run_pain(_delta)
	if _lastAnimFinishSeen != "":
		print("Handle anim finished " + _lastAnimFinishSeen)
		var anim:String = _lastAnimFinishSeen
		_lastAnimFinishSeen = ""
		match anim:
			"body_idle":
				print("Start shooting")
				_start_shooting_right()
				_loops = 5
			"fire_right":
				if _loops <= 0:
					_end_shooting_right()
					return
				_loops -= 1
				_rightMuzzleFlash.start(0.1)

func _process2(delta: float) -> void:
	if _lastAnimFinishProcessed != _lastAnimFinishSeen:
		print("Saw anim change " + str(_lastAnimFinishProcessed) + " to " + _lastAnimFinishSeen)
		_lastAnimFinishProcessed = _lastAnimFinishSeen
	
	var animState:String = _animState.get_current_node()
	var txt:String = "Anim\n"
	#var state = _animTree.get("parameters/playback") as AnimationNodeStateMachinePlayback
	txt += animState + "\n"
	txt += _lastStateNode + "\n"
	txt += str(_animState.get_current_play_position()) + "\n"
	txt += str(_loops)
	_debug.text = txt
	
	# isShootingRight
	# isAimingRight
	match animState:
		"body_idle":
			_tick -= delta
			if _tick <= 0.0:
				print("Start shooting")
				_animTree.set("parameters/conditions/is_aiming_right", true)
				_animTree.set("parameters/conditions/is_shooting_right", true)
				_animTree.set("parameters/conditions/is_winding_down", false)
				_loops = 5
		"fire_right":
			if animState != _lastStateNode:
				_loops -= 1
			if _loops <= 0:
				#print("Stop shooting")
				_animTree.set("parameters/conditions/is_aiming_right", false)
				_animTree.set("parameters/conditions/is_shooting_right", false)
				_animTree.set("parameters/conditions/is_winding_down", true)
				_tick = 1.0
	_lastStateNode = animState
	
