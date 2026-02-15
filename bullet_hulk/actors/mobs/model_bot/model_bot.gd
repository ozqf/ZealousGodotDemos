extends Node

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

func _ready() -> void:
	_animState = _animTree.get("parameters/playback") as AnimationNodeStateMachinePlayback
	_lastStateNode = _animState.get_current_node()
	_animTree.connect("animation_finished", _on_anim_finished)

func _on_anim_finished(anim_name:String) -> void:
	if anim_name == "":
		print("Saw empty anim finish")
	print("Tree anim finished " + str(anim_name))
	_lastAnimFinishSeen = anim_name
	

func _start_shooting_right() -> void:
	_animTree.set("parameters/conditions/is_aiming_right", true)
	_animTree.set("parameters/conditions/is_shooting_right", true)
	_animTree.set("parameters/conditions/is_winding_down", false)

func _end_shooting_right() -> void:
	_animTree.set("parameters/conditions/is_aiming_right", false)
	_animTree.set("parameters/conditions/is_shooting_right", false)
	_animTree.set("parameters/conditions/is_winding_down", true)

func _physics_process(_delta: float) -> void:
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
	
