extends KinematicBody

onready var _mouse:MouseLook = $mouse
onready var _debugLabel:Label = $ui/debug

var _inputOn:bool = true
var _velocity:Vector3 = Vector3()

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta:float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_inputOn = !_inputOn
		_mouse.set_input_on(_inputOn)
		if _inputOn:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _read_move_input() -> Vector3:
	var dir:Vector3 = Vector3()
	if Input.is_action_pressed("move_forward"):
		dir.z += -1
	if Input.is_action_pressed("move_backward"):
		dir.z -= -1
	if Input.is_action_pressed("move_left"):
		dir.x += -1
	if Input.is_action_pressed("move_right"):
		dir.x -= -1
	if Input.is_action_pressed("move_up"):
		dir.y -= -1
	if Input.is_action_pressed("move_down"):
		dir.y += -1
	return dir

func _apply_rotation(mouse:Vector2) -> void:
	var rot:Vector3 = rotation_degrees
	rot.y += mouse.x
	rot.x += mouse.y
	rotation_degrees = rot

func _calc_input_push(dir:Vector3) -> Vector3:
	var rotMatrix:Basis = global_transform.basis
	var move:Vector3 = Vector3()
	move += (rotMatrix.z * dir.z)
	move += (rotMatrix.x * dir.x)
	move += (rotMatrix.y * dir.y)
	return move

func _apply_debug_move(inputDir:Vector3, _delta:float) -> void:
	var t:Transform = global_transform
	var p:Vector3 = t.origin
	p += inputDir * (10 * _delta)
	t.origin = p
	global_transform = t

func _apply_move(inputDir:Vector3, _delta:float) -> void:
	var txt:String = ""
	var t:Transform = global_transform
	if !_inputOn:
		txt += "Mouse free\n"
	# var framePush:Vector3 = inputDir * (10 * _delta)
	var framePush:Vector3 = inputDir * (10)
	
	var forward:Vector3 = -t.basis.z
	var pushNormal:Vector3 = framePush.normalized()
	var velNormal:Vector3 = _velocity.normalized()
	# var dot:float = _velocity.dot(framePush)
	var dot:float = pushNormal.dot(velNormal)
	var dot2:float = _velocity.dot(forward)
	txt += "velocity framePush Dot: " + str(dot) + "\n"
	txt += "forward framePush Dot: " + str(dot2) + "\n"
	
	_velocity += (framePush * _delta)
	move_and_slide(_velocity)
	
#	var p:Vector3 = t.origin
#	p += _velocity
#	t.origin = p
#	global_transform = t
	_debugLabel.text = txt

func _physics_process(_delta:float) -> void:
	_apply_rotation(_mouse.read_accumulator())
	var inputPush:Vector3 = _calc_input_push(_read_move_input())
	_apply_move(inputPush, _delta)
	pass
