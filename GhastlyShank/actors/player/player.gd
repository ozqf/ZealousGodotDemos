extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var _rageType:PackedScene = preload("res://actors/rage_drop/rage_drop.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _head:Node3D = $head

@onready var _rightAnimator:PlayerAttackAnimator = $head/right_new/AnimationPlayer

@onready var _moveDirIcon:Control = $hud/crosshair/move_direction
@onready var _lookDirIcon:Control = $hud/crosshair/look_direction

@onready var _leftHand:Node3D = $head/left

var _tick:float = 0.0
var _tickMax:float = 0.25
var _swinging:bool = false

var _spellTick:float = 0.0

var _nextSwingType:int = -1
var _lastSwingType:int = -1

var _a:Transform3D
var _b:Transform3D

var _timeSinceLastMouseDelta:float = 0.0
var _mouseDelta:Vector2 = Vector2()
var _movePushDelta:Vector2 = Vector2()

func _ready() -> void:
	#_rightAnimator.play("swing_right_to_left")
	pass

###################################################
# Attack
###################################################

func _get_move_based_swing_type(move:Vector2) -> int:
	if move.is_zero_approx():
		return 3
	if move.x < 0:
		return 1
	elif move.x > 0:
		return 0
	elif move.y > 0:
		return 2
	return 3
#	var lookMoveDegrees:float = rad_to_deg(atan2(_mouseDelta.y, _mouseDelta.x))
#	if lookMoveDegrees

func _get_look_based_swing_type(look:Vector2) -> int:
	var lookMoveDegrees:float = rad_to_deg(atan2(_mouseDelta.y, _mouseDelta.x))
	lookMoveDegrees = ZqfUtils.cap_degrees(lookMoveDegrees)
	# up 270, down 90, right 0, left 180
	# +x is right, +y is down
#	if lookMoveDegrees < 
	
	return 2

func _physics_process_attack(_delta:float) -> void:
	if Input.is_action_pressed("attack_2") && !_swinging:
		_leftHand.rotation_degrees.y = 0
	else:
		_leftHand.rotation_degrees.y = 125
	if _swinging:
		return
	if Input.is_action_pressed("attack_1"):
		
		_nextSwingType = _get_move_based_swing_type(_movePushDelta)
		_rightAnimator.play_attack()
	elif Input.is_action_pressed("attack_3") && _spellTick <= 0.0:
		var drop = _rageType.instantiate()
		get_parent().add_child(drop)
		var t:Transform3D = _head.global_transform
		var origin:Vector3 = t.origin
		var forward:Vector3 = -t.basis.z
		drop.launch(origin, forward)
		_spellTick = 0.1
		pass

func _process(delta:float):
	_timeSinceLastMouseDelta += delta
	if _timeSinceLastMouseDelta < 0.05:
		var lookMoveDegrees:float = rad_to_deg(atan2(_mouseDelta.y, _mouseDelta.x))
		_lookDirIcon.rotation_degrees = lookMoveDegrees
		lookMoveDegrees = ZqfUtils.cap_degrees(lookMoveDegrees)
	else:
		_lookDirIcon.rotation_degrees = 270
	
	if !_movePushDelta.is_zero_approx():
		var movePushDegrees:float = rad_to_deg(atan2(_movePushDelta.y, _movePushDelta.x))
		_moveDirIcon.rotation_degrees = movePushDegrees
	else:
		_moveDirIcon.rotation_degrees = 270

###################################################
# Movement
###################################################

func _physics_process_move(delta:float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	_movePushDelta = input_dir
	
	if Zqf.has_mouse_claims():
		input_dir = Vector2()
	var direction:Vector3 = (_head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func _input(event) -> void:
	if Zqf.has_mouse_claims():
		return
	var motion:InputEventMouseMotion = event as InputEventMouseMotion
	if motion == null:
		return
	var ratio:Vector2 = ZqfUtils.get_window_to_screen_ratio()
	var invertedMul:float = -1
	
	var dx:float = (-motion.relative.x) * 0.2 * ratio.x
	var dy:float = ((-motion.relative.y) * 0.2) * ratio.y * invertedMul
	
	_timeSinceLastMouseDelta = 0.0
	_mouseDelta.x = -dx
	_mouseDelta.y = -dy

	# apply
	var degrees:Vector3 = _head.rotation_degrees
	degrees.y += dx
	degrees.x += dy
	degrees.x = clampf(degrees.x, -89, 89)
	_head.rotation_degrees = degrees

func _physics_process(delta:float):
	if _spellTick > 0:
		_spellTick -= delta
	_physics_process_move(delta)
	_physics_process_attack(delta)
