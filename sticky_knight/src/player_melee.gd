extends Node2D
class_name PlayerMelee

const ATTACK_LINE_LENGTH:float = 96.0
const ATTACK_TIME:float = 0.05
const ATTACK_RECOVER_TIME:float = 0.2

const STATE_READY:int = 0
const STATE_SWING:int = 1
const STATE_RECOVER:int = 2
const AABB_ONLY:bool = true

@onready var _attackLine:Line2D = $melee_area/attack_line
@onready var _shape:CollisionShape2D = $melee_area/CollisionShape2D
@onready var _attackArea:Area2D = $melee_area

var _state:int = STATE_READY
var _attackDir = Vector2(1, 0)
var _attackTick:float = 0
var _lastMoveDir = Vector2(1, 0)
var player = null

func _ready():
	var _f1 = _attackArea.connect("area_entered", Callable(self, "_on_melee_area_entered"))
	var _f2 = _attackArea.connect("body_entered", Callable(self, "_on_melee_body_entered"))
	_shape.disabled = true
	_attackLine.visible = false

func _on_melee_body_entered(_body:PhysicsBody2D):
	if _body.has_method("hit"):
		_body.hit()

func _on_melee_area_entered(_area:Area2D):
	if _area.has_method("hit"):
		_area.hit()
		return
	if _area.has_method("hit_projectile"):
		_area.hit_projectile(rotation)

func set_last_move_dir(dir:Vector2):
	_lastMoveDir = dir
	
func _process_ready(_delta):
	var _inputDir = Vector2()
	if Input.is_action_pressed("ui_left"):
		_inputDir.x -= 1.0
	if Input.is_action_pressed("ui_right"):
		_inputDir.x += 1.0
	if Input.is_action_pressed("ui_up"):
		_inputDir.y -= 1.0
	if Input.is_action_pressed("ui_down"):
		_inputDir.y += 1.0
	# switch to prevent attacks at 45 degrees:
#	if AABB_ONLY:
#		if _lastMoveDir.x != 0
	_inputDir = _inputDir.normalized()
	if _inputDir.length() == 0:
		_inputDir = _lastMoveDir
	_attackLine.self_modulate = Color(1, 1, 1)
	rotation_degrees = rad_to_deg(atan2(_inputDir.y, _inputDir.x))
	#	_attackLine.points[1].x = _inputDir.x * ATTACK_LINE_LENGTH
	#	_attackLine.points[1].y = _inputDir.y * ATTACK_LINE_LENGTH
	if Input.is_action_pressed("attack_1"):
		_state = STATE_SWING
		_shape.disabled = false
		_attackLine.visible = true
		_attackTick = ATTACK_TIME
		_attackLine.self_modulate = Color(1, 0, 0)
		if player != null:
			player.on_attack(_inputDir)

func _process_swing(_delta):
	if _attackTick > 0:
		_attackTick -= _delta
	else:
		_attackTick = ATTACK_RECOVER_TIME
		_state = STATE_RECOVER
		_shape.disabled = true
		_attackLine.visible = false

func _process_recover(_delta):
	if _attackTick > 0:
		_attackTick -= _delta
	else:
		_state = STATE_READY
		_shape.disabled = true
		_attackLine.visible = false

func _process(_delta):
	if _state == STATE_SWING:
		_process_swing(_delta)
	elif _state == STATE_RECOVER:
		_process_recover(_delta)
	else:
		_process_ready(_delta)
