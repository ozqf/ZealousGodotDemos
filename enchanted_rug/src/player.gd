extends KinematicBody

onready var _mouse:MouseLook = $mouse
onready var _debugLabel:Label = $ui/debug

const maxSpeed:float = 15.0
# const pushForce:float = 2000.0

var _inputOn:bool = true
var _velocity:Vector3 = Vector3()

var _spawnTransform:Transform = Transform.IDENTITY
var _prevTransform:Transform = Transform.IDENTITY

var _moveMode:int = 3

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_spawnTransform = global_transform
	_prevTransform = global_transform

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

func _apply_debug_move(inputDir:Vector3, _delta:float) -> String:
	var t:Transform = global_transform
	var p:Vector3 = t.origin
	p += inputDir * (maxSpeed * _delta)
	t.origin = p
	global_transform = t
	return ""

func _calc_velocity() -> Vector3:
	var prev:Vector3 = _prevTransform.origin
	var cur:Vector3 = global_transform.origin
	return (cur - prev)

func _apply_move_1(inputDir:Vector3, _delta:float) -> String:
	var txt:String = "Quake accel style\n"
	inputDir = inputDir.normalized()
	# apply drag
	if inputDir.length() == 0:
		_velocity *= 0.8
	
	var curDir:Vector3 = _velocity.normalized()
	# dot from normalised values:
	# var projectionVelDot:float = inputDir.dot(curDir)
	# dot from raw values:
	var projectionVelDot:float = inputDir.dot(_velocity)
	
	var accelStr:float = maxSpeed * 10
	
	var accelMag:float = accelStr * _delta
	if (projectionVelDot + accelMag > maxSpeed):
		accelMag = maxSpeed - projectionVelDot
	
	var framePush:Vector3 = inputDir * accelMag
	_velocity += framePush
	_velocity = move_and_slide(_velocity)
	
	txt += "Move dir: " + str(inputDir) + "\n"
	txt += "Cur dir: " + str(curDir) + "\n"
	txt += "Move dot: " + str(projectionVelDot) + "\n"
	txt += "Push limited: " + str(framePush * projectionVelDot) + "\n"
	txt += "Speed: " + str(_velocity.length()) + "\n"
	return txt

func _apply_move_2(inputDir:Vector3, _delta:float) -> String:
	var txt:String = ""
	var t:Transform = global_transform
	var forward:Vector3 = -t.basis.z
	# var framePush:Vector3 = inputDir * (10 * _delta)
	# frame push should scale by
	# a: max velocity
	# b: difference from current direction
	
	# if speed is low, push force is high -> snappier speed changes
	# if speed is high push is close to current direction:
	#	
	var pushForce:float = maxSpeed * 10
	var framePush:Vector3 = inputDir.normalized() * pushForce
	var potentialPush:Vector3 = forward * pushForce
	
	var pushNormal:Vector3 = framePush.normalized()
	var velNormal:Vector3
	if _velocity.length() > 0:
		velNormal = _velocity.normalized()
	else:
		velNormal = forward
	var curSpeed:float = _velocity.length()
	# var dot:float = _velocity.dot(framePush)
	var dot:float
	if _velocity.length() > 0:
		dot = pushNormal.normalized().dot(velNormal) # * -1
	else:
		dot = 1
	var potentialDot:float = potentialPush.normalized().dot(velNormal) * -1
	var dot2:float = _velocity.dot(forward)
	# var inputPushScale:float = 1 - (pow(curSpeed / maxSpeed, 3))
	var inputPushScale:float = potentialDot
	if inputPushScale < 0:
		inputPushScale = 0
	# var speedCapacity:float = maxSpeed - curSpeed
	var speedCapacity:float = 1 - (curSpeed / maxSpeed)
	if speedCapacity < 0:
		speedCapacity = 0
	elif speedCapacity > 1:
		speedCapacity = 1
	# drag is a reverse of velocity, scaling up as velocity increases
	var drag:Vector3 = (-_velocity.normalized() * maxSpeed) * (1 - speedCapacity)
	
	_velocity += (framePush * inputPushScale) * _delta
	_velocity = move_and_slide(_velocity)
	
	txt += "Speed: " + str(curSpeed) + "\n"
	txt += "Forward: " + str(forward) + "\n"
	txt += "Velocity Normal" + str(velNormal) + "\n"
	txt += "Potential framePush Dot: " + str(potentialDot) + "\n"
	txt += "PushScale: " + str(inputPushScale) + "\n"
	txt += "Potential push: " + str(potentialPush) + "\n"
	
	txt += "Speed capacity %: " + str(speedCapacity) + "\n"
	txt += "Push scale: " + str(inputPushScale) + "\n"
	
	txt += "Drag str: " + str(drag.length()) + "\n"
	txt += "Drag: " + str(drag) + "\n"

	return txt

func _apply_move_3(inputDir:Vector3, _delta:float) -> String:
	var pushStr:float = maxSpeed
	var pushNormal:Vector3 = inputDir.normalized()
	var velNormal:Vector3
	var curSpeed:float = _velocity.length()
	if curSpeed > 0:
		velNormal = _velocity.normalized()
	else:
		velNormal = -global_transform.basis.z
	
	_velocity += (pushNormal * pushStr) * _delta
	_velocity = move_and_slide(_velocity)
	
	var txt:String = ""
	txt += "Speed/Max: " + str(curSpeed) + " / " + str(maxSpeed) + "\n"
	txt += "Move normaL: " + str(velNormal) + "\n"
	txt += "Push normal: " + str(pushNormal) + "\n"
	return txt

func _apply_move_4(inputDir:Vector3, _delta:float) -> String:
	
	var txt:String = ""
	return txt

func _physics_process(_delta:float) -> void:
	if Input.is_action_just_pressed("reset"):
		_velocity = Vector3()
		global_transform = _spawnTransform
	if Input.is_action_just_pressed("mode"):
		_moveMode += 1
		if _moveMode > 4:
			_moveMode = 0
	
	_apply_rotation(_mouse.read_accumulator())
	var inputPush:Vector3 = _calc_input_push(_read_move_input())
	var txt = ""
	if _moveMode == 1:
		txt = _apply_move_1(inputPush, _delta)
	elif _moveMode == 2:
		txt = _apply_move_2(inputPush, _delta)
	elif _moveMode == 3:
		txt = _apply_move_3(inputPush, _delta)
	elif _moveMode == 4:
		txt = _apply_move_4(inputPush, _delta)
	else:
		txt = _apply_debug_move(inputPush, _delta)
	pass
	if !_inputOn:
		txt += "Mouse free\n"
	txt = "Mode: " + str(_moveMode) + "\n" + txt
	_debugLabel.text = txt
