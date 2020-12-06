extends KinematicBody2D

var _projectile_prefab = preload("res://prefabs/projectile.tscn")

const STATE_NONE:int = 0
const STATE_ATTACK_WINDUP:int = 1
const STATE_ATTACK_WINDDOWN:int = 2

const WALK_SPEED:float = 100.0
const AIM_TIME:float = 0.5
const REFIRE_TIME:float = 1.0
const THINK_TIME:float = 0.25

signal enemy_died

onready var _left:WorldSensor = $left
onready var _right:WorldSensor = $right
onready var _leftFloor:WorldSensor = $left_floor
onready var _rightFloor:WorldSensor = $right_floor
onready var _sprite:Sprite = $Sprite
onready var _los:RayCast2D = $line_of_sight
onready var _losMarker:Node2D = $los_marker

var _velocity = Vector2()
var _gravity = Vector2(0, 900)
var _moveDir = Vector2(150, 0)
var _attackDegrees:float = 0

var _target:Node2D = null
var _tick:float = 0
var _state:int = 0
var _hasLOS:bool = false

func hit():
	emit_signal("enemy_died", self)
	queue_free()

func found_player(_plyr:Node2D):
	print("Grunt found player")
	_target = _plyr

func lost_player(_plyr:Node2D):
	print("Grunt lost player")
	_target = null

func _walk(_delta):
	if _moveDir.x > 0:
		# moving right - check turn
		if _right.on() || !_rightFloor.on():
			_velocity.x = -WALK_SPEED
			_moveDir.x = -1
		pass
	elif _moveDir.x < 0:
		# moving left
		if _left.on() || !_leftFloor.on():
			_velocity.x = WALK_SPEED
			_moveDir.x = 1
		pass
	else:
		_moveDir.x = 1
		_velocity.x = 0
	_velocity.y += _gravity.y * _delta
	_velocity = move_and_slide(_velocity, Vector2.UP)
	_sprite.flip_h = (_velocity.x < 0)

func _has_los(tar):
	if tar == null:
		return false
	return !_los.is_colliding()

func _refresh_los_pos(tar:Node2D):
	if tar == null:
		_hasLOS = false
		return
	var selfPos:Vector2 = global_position
	var destPos:Vector2 = tar.global_position
	destPos.y -= 16
	var diff := destPos - selfPos
	_los.set_cast_to(diff)
	_losMarker.position = diff
	# if hitting, something is blocking the ray, so we
	# DON'T have LoS
	_hasLOS = !_los.is_colliding()
	var hitObj = _los.get_collider()
	if hitObj == null:
		#game.set_debug_text(" no hit")
		return
	#game.set_debug_text(" hit: " + str(hitObj.name))
	# print("Diff " + str(diff))

func _attack_target():
	var prj:Projectile = _projectile_prefab.instance()
	var parent = get_tree().get_current_scene()
	parent.add_child(prj)
	prj.launch(null, _sprite.global_position, deg2rad(_attackDegrees), 250, game.TEAM_ENEMY)

func _physics_process(_delta):
	_refresh_los_pos(_target)
	if _state == STATE_NONE:
		_tick -= _delta
		if _tick > 0:
			_walk(_delta)
		else:
			if _has_los(_target) && is_on_floor():
				_tick = AIM_TIME
				_state = STATE_ATTACK_WINDUP
			else:
				_tick = THINK_TIME
	elif _state == STATE_ATTACK_WINDUP:
		_tick -= _delta
		if _target != null:
			# set attack left or right
			if _target.position.x >= position.x:
				_attackDegrees = 0
			else:
				_attackDegrees = 180
		if _tick <= 0:
			_attack_target()
			_tick = REFIRE_TIME
			_state = STATE_ATTACK_WINDDOWN
	elif _state == STATE_ATTACK_WINDDOWN:
		_tick -= _delta
		if _tick <= 0:
			_tick = THINK_TIME
			_state = STATE_NONE
