extends Node

@onready var _weaponModel:Node3D = $weapon_model

@onready var _rightHighStart:Node3D = $right/right_high_start
@onready var _rightHighEnd:Node3D = $right/right_high_end

@onready var _leftHighStart:Node3D = $right/left_high_start
@onready var _leftHighEnd:Node3D = $right/left_high_end

@onready var _thrustStart:Node3D = $right/thrust_start
@onready var _thrustEnd:Node3D = $right/thrust_end

@onready var _leftHand:Node3D = $left

var _tick:float = 0.0
var _tickMax:float = 0.25
var _swinging:bool = false

var _nextSwingType:int = 0

var _a:Transform3D
var _b:Transform3D

func _ready():
	pass # Replace with function body.

func _run_swing(duration:float, start:Transform3D, end:Transform3D):
	_swinging = true
	_tick = 0.0
	_tickMax = duration
	_a = start
	_b = end

#func _swing_right_high() -> void:
#	_swinging = true
#	_tick = 0.0
#	_tickMax = 0.4
#	_a = _rightHighStart.transform
#	_b = _rightHighEnd.transform
#
#func _swing_left_high() -> void:
#	_swinging = true
#	_tick = 0.0
#	_tickMax = 0.4
#	_a = _leftHighStart.transform
#	_b = _leftHighEnd.transform

func _auto_swing() -> void:
	match _nextSwingType:
		0:
			_nextSwingType = 1
#			_swing_right_high()
			_run_swing(0.4, _rightHighStart.transform, _rightHighEnd.transform)
		1:
			_nextSwingType = 0
#			_swing_left_high()
			_run_swing(0.4, _leftHighStart.transform, _leftHighEnd.transform)
		2:
			_nextSwingType = 0
			_run_swing(0.2, _thrustStart.transform, _thrustEnd.transform)

			

func _physics_process(_delta:float) -> void:
	if Input.is_action_pressed("attack_2") && !_swinging:
		_leftHand.rotation_degrees.y = 0
	else:
		_leftHand.rotation_degrees.y = 105
	if _swinging:
		return
	if Input.is_action_pressed("attack_1"):
		_auto_swing()
	elif Input.is_action_pressed("attack_3"):
		_run_swing(0.2, _thrustStart.transform, _thrustEnd.transform)
		

func _process(delta:float):
	if _swinging:
		_tick += delta
		if _tick > _tickMax:
			_tick = 0.0
			_swinging = false
		var weight:float = _tick / _tickMax
		_weaponModel.transform = _a.interpolate_with(_b, weight)
