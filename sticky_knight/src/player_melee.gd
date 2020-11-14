extends Area2D
class_name PlayerMelee

const ATTACK_LINE_LENGTH:float = 96.0
const ATTACK_TIME:float = 0.2

onready var _attackLine:Line2D = $attack_line
onready var _shape:CollisionShape2D = $CollisionShape2D
var _attackDir = Vector2(1, 0)
var _attackTick:float = 0

var _lastMoveDir = Vector2(1, 0)

func set_last_move_dir(dir:Vector2):
	_lastMoveDir = dir

func _process(_delta):
	if _attackTick > 0:
		_attackTick -= _delta
		if _attackTick <= 0:
			_shape.disabled = true
		return
	var _inputDir = Vector2()
	if Input.is_action_pressed("ui_left"):
		_inputDir.x -= 1.0
	if Input.is_action_pressed("ui_right"):
		_inputDir.x += 1.0
	if Input.is_action_pressed("ui_up"):
		_inputDir.y -= 1.0
	if Input.is_action_pressed("ui_down"):
		_inputDir.y += 1.0
	_inputDir = _inputDir.normalized()
	if _inputDir.length() == 0:
		_inputDir = _lastMoveDir
	_attackLine.self_modulate = Color(1, 1, 1)
	_attackLine.points[1].x = _inputDir.x * ATTACK_LINE_LENGTH
	_attackLine.points[1].y = _inputDir.y * ATTACK_LINE_LENGTH
	if Input.is_action_pressed("attack_1"):
		_shape.disabled = false
		_attackTick = ATTACK_TIME
		_attackLine.self_modulate = Color(1, 0, 0)
