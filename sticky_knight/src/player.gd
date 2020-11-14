extends KinematicBody2D

const SPEED_X = 250.0
const JUMP_STRENGTH = 360
const MAX_AIR_JUMPS = 1

onready var _melee: PlayerMelee = $melee
onready var _airJumpSprite: Sprite = $air_jump_sprite
onready var _groundedSprite: Sprite = $grounded_sprite

var _velocity = Vector2()
var _gravity = Vector2(0, 900)
var _lastMoveDir = Vector2(1, 0)
var _airJumps:int = 1
var _frame:int = 0

func _physics_process(_delta):
	_frame += 1
	var pushX = 0.0
	if Input.is_action_pressed("ui_left"):
		pushX -= 1.0
	if Input.is_action_pressed("ui_right"):
		pushX += 1.0
	_velocity.x = pushX * SPEED_X
	
	_airJumpSprite.visible = (_airJumps > 0)
	_groundedSprite.visible = is_on_floor()
	
	if is_on_floor():
		_airJumps = MAX_AIR_JUMPS
		if Input.is_action_just_pressed("jump"):
			# print(str(_frame) + " Jump")
			_velocity.y = -JUMP_STRENGTH
			#_velocity.y = -500
		pass
	else:
		if _airJumps > 0 && Input.is_action_just_pressed("jump"):
			# print(str(_frame) + " Air jump")
			_velocity.y = -JUMP_STRENGTH
			_airJumps -= 1
	
	# gravity must always be applied even when on ground
	# otherwise is_on_floor will fail if move_and_slide
	# has no y component into the floor!
	_velocity.y += _gravity.y * _delta
	
	# update default face direction
	if _velocity.x > 0:
		_lastMoveDir = Vector2(1, 0)
		_melee.set_last_move_dir(Vector2(1, 0))
	elif _velocity.x < 0:
		_lastMoveDir = Vector2(-1, 0)
		_melee.set_last_move_dir(Vector2(-1, 0))
	
	_velocity = move_and_slide(_velocity, Vector2.UP)
