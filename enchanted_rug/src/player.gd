extends KinematicBody

onready var _mouse:MouseLook = $mouse
onready var _debugLabel:Label = $ui/debug
onready var _altitudeRay:RayCast = $altitude_ray
onready var _head:Spatial = $head
onready var _body:Spatial = $body

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
		"value": 125,
		"default": 125,
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
	"moveMode": 2,
	"velocity": Vector3(),
	"groundPos": Vector3(),
	"pushNormal": Vector3(),
	"projectedPushNormal": Vector3(),
	"pushAccumulator": Vector3(),
	"altitude": 0.0,
	"speedScalar": 0.0,
	"pushVelDot": 0.0,
	"currentSpeed": 0.0,
	"addSpeed": 0.0,
	"accelSpeed": 0.0,
	"acceleration": Vector3(),
	"drag": Vector3(),
	"dragStrength": 0.0,
	"speedCapacity": 1.0,
	"canPush": 0.0,
	"gravityDot": 0.0,
	"gravityDrag": 150.0,
	"gravityStrength": 10.0
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
	add_to_group(Main.GROUP_NAME)
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	refresh_input_flag(false)
	_spawnTransform = global_transform
	_prevTransform = global_transform
	$head/draw_velocity.init(_vars, "velocity", Color.blue, 0.05)
	$head/draw_drag.init(_vars, "drag", Color.red, 0.05)
	$head/draw_push_normal.init(_vars, "pushNormal", Color.white, 1)
	$head/draw_push.init(_vars, "projectedPushNormal", Color.yellow, 1)
	$head/draw_acceleration.init(_vars, "acceleration", Color.orange, 1)

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

func game_reset() -> void:
	_vars.velocity = Vector3()
	global_transform = _spawnTransform

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

func _apply_rotation(spatialNode:Spatial, mouse:Vector2) -> void:
	var rot:Vector3 = spatialNode.rotation_degrees
	rot.y += mouse.x
	rot.x += mouse.y
	spatialNode.rotation_degrees = rot

func _calc_input_push(dir:Vector3) -> Vector3:
	var rotMatrix:Basis = _head.global_transform.basis
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

func _calc_gravity(inputNormal:Vector3, _delta:float) -> Vector3:
	var dot:float = inputNormal.dot(Vector3.DOWN)
	_vars.gravityDot = dot
	var gravityStr:float = _vars.gravityStrength
	if dot == 0:
		return Vector3()
	if dot < 0:
		# return Vector3()
		# apply a mild drag to climbing...?
		var drag:float = gravityStr * 2
		return (Vector3.DOWN * drag * (-dot)) * _delta
	else:
		return (Vector3.DOWN * gravityStr * dot) * _delta

func _apply_move_2(inputDir:Vector3, _delta:float) -> String:
	var velocity:Vector3 = _vars.velocity
	inputDir = inputDir.normalized()
	_vars.pushNormal = inputDir
	# no input? apply drag
	if inputDir.length() == 0:
		velocity *= 0.9
	
	# normally speed cap is max player push...
	var speedCap:float = settings.maxPushSpeed.value
	var curSpeed:float = velocity.length()
	# ...however external pushes may override it
	if curSpeed > speedCap:
		speedCap = curSpeed
	
	# apply player input
	var framePush:Vector3 = (inputDir * settings.pushStrength.value) * _delta
	velocity += framePush
	# cap if necessary
	if velocity.length() > speedCap:
		velocity = velocity.normalized()
		velocity *= speedCap
	
	# apply gravity
	var gravity:Vector3 = _calc_gravity(inputDir, _delta)
	_vars.acceleration = gravity
	velocity += gravity

	# apply external pushes
	var externalPush:Vector3 = read_accumulated_impulse() * _delta
	velocity += externalPush
	
	# move
	velocity = move_and_slide(velocity)

	_vars.velocity = velocity
	return ""

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

# not functioning, retrieved from defunct code in quake 3:
# https://github.com/id-Software/Quake-III-Arena/blob/master/code/game/bg_pmove.c#L260
func _calc_accel_q3_fixed_style(vel:Vector3, wishDir:Vector3, wishSpeed:float, accelStrength:float, delta:float) -> Vector3:
	var wishVel:Vector3 = wishDir * wishSpeed
	var pushDir:Vector3 = wishVel - vel
	var pushLen:float = pushDir.length()
	pushDir = pushDir.normalized()
	_vars.canPush = accelStrength * delta * wishSpeed
	if _vars.canPush > pushLen:
		_vars.canPush = pushLen
	return ZqfUtils.VectorMA(_vars.velocity, _vars.canPush, pushDir)

##############################################
# yet another attempt
func _calc_projected_push(vel:Vector3, wishDir:Vector3, wishSpeed:float, accelStr:float, delta:float) -> Vector3:
	var curSpeed:float = vel.length()
	var projection:Vector3 = wishDir.project(vel)
	_vars.projectedPushNormal = projection
	var dot:float = vel.normalized().dot(wishDir)
	var unadjustedPush = (wishDir * accelStr) * delta
	# if push is against velocity or we are not moving at all
	# no shenanigans required. allow for maximum push strength
	if dot < 0 || curSpeed == 0:
		return unadjustedPush
	
	# will this acceleration push us over wishSpeed?
	var unadjustedMag:float = (vel + unadjustedPush).length()
	if unadjustedMag < wishSpeed:
		return unadjustedPush
	
	# scale projected push by ratio of speed to desired speed
	var ratio:float = curSpeed / wishSpeed
	var _result = wishDir * (accelStr * ratio) * delta
	return Vector3()


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
	
	# _vars.acceleration = _calc_accel_source_style(_vars.velocity, _vars.pushNormal, maxSpeed, pushStr, _delta)
	_vars.acceleration = _calc_accel_q3_fixed_style(_vars.velocity, _vars.pushNormal, maxSpeed, pushStr, _delta)
	# _vars.acceleration
	_vars.acceleration = _calc_projected_push(_vars.velocity, _vars.pushNormal, maxSpeed, pushStr, _delta)
	
	# if dot > 0 push is in a similar direction. 1 == identical
	# if dot < 0 push is against direction. -1 == opposite
	_vars.pushVelDot = _vars.pushNormal.dot(velNormal)
	
	var framePush:Vector3 = (_vars.pushNormal * pushStr) * _delta
	# scale by whether the player is pushing against their current movement:
	# framePush += (framePush * _vars.pushVelDot)

	var externalPush:Vector3 = read_accumulated_impulse() * _delta
	
	# var predictedVelocity:Vector3 = _vars.velocity + framePush
	# var percentageOfMax:float = predictedVelocity.length() / maxSpeed
	# if framePush.length() > 0:
	# 	if percentageOfMax < 1:
	# 		_vars.velocity += framePush
	# 	else:
	# 		# _vars.velocity = pushNormal * maxSpeed
	# 		# apply then cap
	# 		_vars.velocity += framePush
			# _vars.velocity = _vars.velocity.normalized() * maxSpeed
			# framePush *= (percentageOfMax - 1)
	#elif externalPush.length_squared() == 0:
		# apply drag
	#	_vars.velocity *= 0.9
	
	# _vars.drag = _calc_drag(_vars.velocity, maxSpeed)
	
	_vars.velocity += _vars.acceleration
	# _vars.velocity += _vars.acceleration
	# _vars.velocity += framePush
	_vars.velocity += externalPush
	# _vars.velocity += _vars.drag * _delta
	
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

func _update_body_rotation(_delta:float) -> void:
	var forward:Vector3 = _vars.velocity.normalized()
	if forward.length_squared() == 0:
		forward = _body.global_transform.basis.z
	var up:Vector3 = _head.global_transform.basis.y
	var origin:Vector3 = _body.global_transform.origin
	var dest:Vector3 = origin + forward
	_body.look_at(dest, up)

func _physics_process(_delta:float) -> void:
	# if Input.is_action_just_pressed("reset"):
	# 	_vars.velocity = Vector3()
	# 	global_transform = _spawnTransform
	if Input.is_action_just_pressed("mode"):
		_vars.moveMode += 1
		if _vars.moveMode > 4:
			_vars.moveMode = 0
	# set body rotation

	
	_apply_rotation(_head, _mouse.read_accumulator())
	_update_body_rotation(_delta)

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
