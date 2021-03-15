extends KinematicBody

onready var _mouse:MouseLook = $mouse
onready var _debugLabel:Label = $ui/debug
onready var _altitudeRay:RayCast = $altitude_ray

# const MAX_SPEED:float = 25.0
# const MIN_SPEED:float = 10.0
# const MIN_ALTITUDE:float = 4.0
# const MAX_ALTITUDE:float = 50.0

var settings:Dictionary = {
	"maxPushSpeed": {
		"value": 25.0,
		"default": 25.0,
		"editMin": 1.0,
		"editMax": 100.0
	},
	"minPushSpeed": {
		"value": 10.0,
		"default": 10.0,
		"editMin": 1.0,
		"editMax": 100.0
	},
	"pushStrength": {
		"value": 50,
		"default": 50,
		"editMin": 1,
		"editMax": 500
	},
	"minAltitude": {
		"value": 5.0,
		"default": 5.0,
		"editMin": 1.0,
		"editMax": 100.0
	},
	"maxAltitude": {
		"value": 25.0,
		"default": 25.0,
		"editMin": 1.0,
		"editMax": 100.0
	}
}

var _vars:Dictionary = {
	"moveMode": 3,
	"velocity": Vector3(),
	"groundPos": Vector3(),
	"pushNormal": Vector3(),
	"pushAccumulator": Vector3(),
	"altitude": 0.0,
	"speedScalar": 0.0,
	"pushVelDot": 0.0,
	"velPushDot": 0.0,
	"currentSpeed": 0.0,
	"addSpeed": 0.0,
	"accelSpeed": 0.0,
	"acceleration": Vector3(),
	"drag": Vector3(),
	"dragStrength": 0.0,
	"speedCapacity": 1.0
}

var _inputOn:bool = false
# var _velocity:Vector3 = Vector3()

var _groundHit:bool = false
# var _groundPos:Vector3 = Vector3()
# var _altitude:float = 0
# var _speedScalar:float = 1

var _spawnTransform:Transform = Transform.IDENTITY
var _prevTransform:Transform = Transform.IDENTITY

# var _moveMode:int = 3

func get_settings() -> Dictionary:
	return settings

func get_runtime() -> Dictionary:
	return _vars

func _ready() -> void:
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	refresh_input_flag(false)
	_spawnTransform = global_transform
	_prevTransform = global_transform
	$draw_velocity.init(_vars, "velocity", Color.blue, 0.05)
	$draw_drag.init(_vars, "drag", Color.red, 0.05)
	$draw_push_normal.init(_vars, "pushNormal", Color.white, 1)

func _process(_delta:float) -> void:
	var pos:Vector3 = global_transform.origin
	var hit:Dictionary = ZqfUtils.hitscan_by_pos_3D(self, pos, Vector3.DOWN, settings.maxAltitude.value, [], 1)
	if hit:
		_groundHit = true
		_vars.groundPos = hit.position
		_vars.altitude = pos.y - _vars.groundPos.y
	else:
		_groundHit = false
		_vars.altitude = settings.maxAltitude.value
	
	# var pos:Vector3 = global_transform.origin
	# _altitudeRay.set_cast_to(pos + Vector3(0, -100, 0))
	# if Input.is_action_just_pressed("ui_cancel"):
	# 	_inputOn = !_inputOn
	# 	_mouse.set_input_on(_inputOn)
	# 	if _inputOn:
	# 		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# 	else:
	# 		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# toggle mouse input in event for HTML5
func _input(_event: InputEvent) -> void:
	var menuCode = KEY_TAB
	if _event is InputEventKey && _event.scancode == menuCode && _event.pressed && !_event.echo:
		_toggle_menu()
#		if _inputOn:
#			print("Toggle menu on")
#			set_input_off()
#		else:
#			print("Toggle menu off")
#			set_input_on()

func _vars_string() -> String:
	var txt:String = "--- runtime vars ---\n"
	var keys = _vars.keys()
	for _i in range(0, keys.size()):
		var val = _vars.get(keys[_i])
		txt += keys[_i] + ": " + str(val) + "\n"
	return txt

func _toggle_menu() -> void:
	refresh_input_flag(!_inputOn)

func refresh_input_flag(flag:bool) -> void:
	_inputOn = flag
	_mouse.set_input_on(_inputOn)
	if _inputOn:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# enable debug menu controls if input off
	$ui.set_editable(!_inputOn)

func add_impulse(push:Vector3) -> void:
	# print("Player add push " + str(push))
	_vars.pushAccumulator += push

func read_accumulated_impulse() -> Vector3:
	var v:Vector3 = _vars.pushAccumulator
	_vars.pushAccumulator = Vector3()
	return v

func _calc_max_by_altitude(scalar:float, minSpeed:float, maximumSpeed:float) -> float:
	var diff:float = maximumSpeed - minSpeed
	return minSpeed + (diff * scalar)

func _calc_drag(velocity:Vector3, maxSpeed:float) -> Vector3:
	var speedCapacity:float = (velocity.length() / maxSpeed)
#	if speedCapacity < 0:
#		speedCapacity = 0
#	elif speedCapacity > 1:
#		speedCapacity = 1
	# drag is a reverse of velocity, scaling up as velocity increases
	var drag:Vector3 = (-velocity.normalized() * maxSpeed) * (speedCapacity)
	_vars.speedCapacity = speedCapacity
	return drag

func _read_move_input() -> Vector3:
	if !_inputOn:
		return Vector3()
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
	p += inputDir * (settings.maxPushSpeed.value * _delta)
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
		_vars.velocity *= 0.8
	
	var curDir:Vector3 = _vars.velocity.normalized()
	# dot from normalised values:
	# var projectionVelDot:float = inputDir.dot(curDir)
	# dot from raw values:
	var projectionVelDot:float = inputDir.dot(_vars.velocity)
	
	var accelStr:float = settings.maxPushSpeed.value * 10
	
	var accelMag:float = accelStr * _delta
	if (projectionVelDot + accelMag > settings.maxPushSpeed.value):
		accelMag = settings.maxPushSpeed.value - projectionVelDot
	
	var framePush:Vector3 = inputDir * accelMag
	
	_vars.velocity += framePush
	_vars.velocity = move_and_slide(_vars.velocity)
	
	txt += "Move dir: " + str(inputDir) + "\n"
	txt += "Cur dir: " + str(curDir) + "\n"
	txt += "Move dot: " + str(projectionVelDot) + "\n"
	txt += "Push limited: " + str(framePush * projectionVelDot) + "\n"
	txt += "Speed: " + str(_vars.velocity.length()) + "\n"
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
	var pushForce:float = settings.maxPushSpeed.value * 10
	var framePush:Vector3 = inputDir.normalized() * pushForce
	var potentialPush:Vector3 = forward * pushForce
	
	var pushNormal:Vector3 = framePush.normalized()
	var velNormal:Vector3
	if _vars.velocity.length() > 0:
		velNormal = _vars.velocity.normalized()
	else:
		velNormal = forward
	var curSpeed:float = _vars.velocity.length()
	# var dot:float = _vars.velocity.dot(framePush)
	var dot:float
	if _vars.velocity.length() > 0:
		dot = pushNormal.normalized().dot(velNormal) # * -1
	else:
		dot = 1
	var potentialDot:float = potentialPush.normalized().dot(velNormal) * -1
	var dot2:float = _vars.velocity.dot(forward)
	# var inputPushScale:float = 1 - (pow(curSpeed / settings.maxPushSpeed.value, 3))
	var inputPushScale:float = potentialDot
	if inputPushScale < 0:
		inputPushScale = 0
	# var speedCapacity:float = settings.maxPushSpeed.value - curSpeed
	var speedCapacity:float = 1 - (curSpeed / settings.maxPushSpeed.value)
	if speedCapacity < 0:
		speedCapacity = 0
	elif speedCapacity > 1:
		speedCapacity = 1
	# drag is a reverse of velocity, scaling up as velocity increases
	var drag:Vector3 = (-_vars.velocity.normalized() * settings.maxPushSpeed.value) * (1 - speedCapacity)
	
	_vars.velocity += (framePush * inputPushScale) * _delta
	_vars.velocity = move_and_slide(_vars.velocity)
	
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

func _calc_accel_source_style(velocity:Vector3, wishDir:Vector3, wishSpeed:float, accelStrength:float, delta:float) -> Vector3:
	var acceleration:Vector3 = Vector3()
	_vars.currentSpeed = velocity.dot(wishDir)
	_vars.addSpeed = wishSpeed - _vars.currentSpeed
	if _vars.addSpeed <= 0:
		return acceleration
	_vars.accelSpeed = accelStrength * delta * wishSpeed
	if _vars.accelSpeed > _vars.addSpeed:
		_vars.accelSpeed = _vars.addSpeed
	acceleration = wishDir * _vars.accelSpeed
	return acceleration

func _apply_move_3(inputDir:Vector3, _delta:float) -> String:
	var maxSpeed:float = _calc_max_by_altitude(_vars.speedScalar, settings.minPushSpeed.value, settings.maxPushSpeed.value)

	# var pushStr:float = maxSpeed * 10
	var pushStr:float = settings.pushStrength.value
	_vars.pushNormal = inputDir.normalized()
	var velNormal:Vector3
	var curSpeed:float = _vars.velocity.length()
	if curSpeed > 0:
		velNormal = _vars.velocity.normalized()
	else:
		velNormal = -global_transform.basis.z
	
	_vars.acceleration = _calc_accel_source_style(_vars.velocity, _vars.pushNormal, maxSpeed, pushStr, _delta)
	
	_vars.pushVelDot = _vars.pushNormal.dot(velNormal) * -1
	_vars.velPushDot = velNormal.dot(_vars.pushNormal) * -1
	if _vars.pushVelDot < 0:
		_vars.pushVelDot = 0
	
	var framePush:Vector3 = (_vars.pushNormal * pushStr) * _delta
	# scale by whether the player is pushing against their current movement:
	# framePush += (framePush * _vars.pushVelDot)

	var externalPush:Vector3 = read_accumulated_impulse()
	
	var predictedVelocity:Vector3 = _vars.velocity + framePush
	var percentageOfMax:float = predictedVelocity.length() / maxSpeed
	if framePush.length() > 0:
		if percentageOfMax < 1:
			_vars.velocity += framePush
		else:
			# _vars.velocity = pushNormal * maxSpeed
			# apply then cap
			_vars.velocity += framePush
			# _vars.velocity = _vars.velocity.normalized() * maxSpeed
			# framePush *= (percentageOfMax - 1)
	#elif externalPush.length_squared() == 0:
		# apply drag
	#	_vars.velocity *= 0.9
	
	_vars.drag = _calc_drag(_vars.velocity, maxSpeed)
	
	_vars.velocity += externalPush * _delta
	_vars.velocity += _vars.drag * _delta
	
	_vars.velocity = move_and_slide(_vars.velocity)
	
	var txt:String = ""
	return txt

func _apply_move_4(_inputDir:Vector3, _delta:float) -> String:
	var maxSpeed:float = _calc_max_by_altitude(_vars.speedScalar, settings.minPushSpeed.value, settings.maxPushSpeed.value)

	var pushStr:float = maxSpeed * 10
	var pushNormal:Vector3 = _inputDir.normalized()
	
	_vars.acceleration = _calc_accel_source_style(_vars.velocity, pushNormal, maxSpeed, pushStr, _delta)
	var externalPush:Vector3 = read_accumulated_impulse()

	_vars.velocity += _vars.acceleration
	_vars.velocity += externalPush * _delta
	_vars.velocity = move_and_slide(_vars.velocity)

	var txt:String = ""
	return txt

func _physics_process(_delta:float) -> void:
	if Input.is_action_just_pressed("reset"):
		_vars.velocity = Vector3()
		global_transform = _spawnTransform
	if Input.is_action_just_pressed("mode"):
		_vars.moveMode += 1
		if _vars.moveMode > 4:
			_vars.moveMode = 0
	
	_apply_rotation(_mouse.read_accumulator())
	var inputPush:Vector3 = _calc_input_push(_read_move_input())
	var txt = ""
	var moveTxt = ""
	if _vars.moveMode == 1:
		moveTxt = _apply_move_1(inputPush, _delta)
	elif _vars.moveMode == 2:
		moveTxt = _apply_move_2(inputPush, _delta)
	elif _vars.moveMode == 3:
		moveTxt = _apply_move_3(inputPush, _delta)
	elif _vars.moveMode == 4:
		moveTxt = _apply_move_4(inputPush, _delta)
	else:
		moveTxt = _apply_debug_move(inputPush, _delta)
	pass
	if !_inputOn:
		moveTxt += "Mouse free\n"
	txt = "Mode: " + str(_vars.moveMode) + "\n" + moveTxt
	txt += "Current Speed: " + str(_vars.velocity.length()) + "\n"
	
	var temp:float = _vars.altitude
	if temp < settings.minAltitude.value:
		temp = 0
	elif temp > settings.maxAltitude.value:
		temp = settings.maxAltitude.value
	_vars.speedScalar = 1 - (temp / settings.maxAltitude.value)
	
#	if _groundHit:
#		txt += "Altitude check hit: " + str(_vars.groundPos) + "\n"
	# txt += "Altitude: " + str(_vars.altitude) + "\n"
	# txt += "Speed scalar: " + str(_vars.speedScalar) + "\n"
	txt += _vars_string()
	_debugLabel.text = txt
