extends KinematicBody

onready var _mouse:MouseLook = $mouse
onready var _debugLabel:Label = $ui/debug
onready var _altitudeRay:RayCast = $altitude_ray
onready var _floorNormalRay:RayCast = $head/floor_normal_ray
onready var _head:Spatial = $head
onready var _body:Spatial = $body
onready var _camera:Camera = $head/Camera
onready var _thirdPersonMount:Spatial = $head/third_person_max
onready var _cameraRay:RayCast = $head/camera_ray
onready var _aimRay:RayCast = $head/aim_ray
onready var _aimPoint:Spatial = $head/aim_ray/aim_point
onready var _nearWorld:ZqfCountOverlaps = $near_world_area
onready var _veryNearWorld:ZqfCountOverlaps = $very_near_world_area
onready var _attack = $attack_control

# fx stuff for showing movement properties
onready var _speedTrail:CPUParticles = $body/rug/speed_trail
onready var _speedTrail2:CPUParticles = $body/rug/speed_trail2
onready var _blueGlow:MeshInstance = $body/rug_blue_power
onready var _redGlow:MeshInstance = $body/rug_red_power

# const MAX_SPEED:float = 25.0
# const MIN_SPEED:float = 10.0
# const MIN_ALTITUDE:float = 4.0
# const MAX_ALTITUDE:float = 50.0

var settings:Dictionary = {
	"maxPushSpeed": {
		"value": 20.0,
		"default": 20.0,
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
		"value": 160,
		"default": 160,
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

var _targetInfo:Dictionary = {
	"valid": true,
	"position": Vector3(),
	"velocity": Vector3(),
	"forward": Vector3()
}

var _inputOn:bool = false
var _groundHit:bool = false
var _spawnTransform:Transform = Transform.IDENTITY
var _prevTransform:Transform = Transform.IDENTITY
var _thirdPersonMode:bool = false
var _cameraDebug:String = ""

var _boostCharge:float = 0.0
var _boostChargeMax:float = 1.0

func get_settings() -> Dictionary:
	return settings

func get_runtime() -> Dictionary:
	return _vars

func get_target_info() -> Dictionary:
	var t:Transform = global_transform
	_targetInfo.position = t.origin
	_targetInfo.forward = -t.basis.z
	_targetInfo.velocity = _vars.velocity
	return _targetInfo

func _ready() -> void:
	add_to_group(Main.GROUP_NAME)
	add_to_group(Console.GROUP)
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	refresh_input_flag(false)
	_spawnTransform = global_transform
	_prevTransform = global_transform
	$head/draw_velocity.init(_vars, "velocity", Color.blue, 0.05)
	$head/draw_drag.init(_vars, "drag", Color.red, 0.05)
	$head/draw_push_normal.init(_vars, "pushNormal", Color.white, 1)
	$head/draw_push.init(_vars, "projectedPushNormal", Color.yellow, 1)
	$head/draw_acceleration.init(_vars, "acceleration", Color.orange, 1)
	
	_cameraRay.cast_to = _thirdPersonMount.transform.origin - _cameraRay.transform.origin
	print("camera ray cast to: " + str(_cameraRay.cast_to))
	_set_third_person(true)

	get_tree().call_group(Main.GROUP_NAME, Main.GAME_PLAYER_ADD_FN, self)

func console_execute(txt:String, _tokens) -> void:
	if txt == "1st":
		_set_third_person(false)
	elif txt == "3rd":
		_set_third_person(true)

func _set_third_person(flag:bool) -> void:
	_thirdPersonMode = flag
	_head.visible = flag
	_body.visible = flag

func _exit_tree():
	get_tree().call_group(Main.GROUP_NAME, Main.GAME_PLAYER_REMOVE_FN, self)

func _update_aim_point() -> void:
	if _aimRay.is_colliding():
		_aimPoint.global_transform.origin = _aimRay.get_collision_point()
	else:
		# foo
		_aimPoint.transform.origin = Vector3(0, 0, -200)
	_attack.set_aim_point(_aimPoint.global_transform.origin)

func _process(_delta:float) -> void:
	var pos:Vector3 = global_transform.origin
	var dest:Vector3 = Vector3(0, -settings.maxAltitude.value, 0)
	var hit:Dictionary = ZqfUtils.hitscan_by_position_3D(self, pos, dest, ZqfUtils.EMPTY_ARRAY, 1)
	#var hit:Dictionary = ZqfUtils.hitscan_by_position_3D(self, pos, Vector3.DOWN, settings.maxAltitude.value, [], 1)
	if hit:
		_groundHit = true
		_vars.groundPos = hit.position
		_vars.altitude = pos.y - _vars.groundPos.y
	else:
		_groundHit = false
		_vars.altitude = settings.maxAltitude.value
	
	_update_camera()
	_update_aim_point()

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

func _update_camera() -> void:
	if !_thirdPersonMode:
		var t:Transform = _camera.transform
		t.origin = Vector3()
		_camera.transform = t
		return
	
	var camFraction:float = 1
	var fullDiff:Vector3 = _cameraRay.cast_to
	if _cameraRay.is_colliding():
		# get current diff. collision point is global and
		# don't get hit fraction for free
		var rayPos:Vector3 = _cameraRay.get_collision_point()
		var originPos:Vector3 = _cameraRay.global_transform.origin
		var diff:Vector3 = rayPos - originPos
		camFraction = diff.length() / fullDiff.length()
		
	if camFraction < 0:
		camFraction = 0
	elif camFraction > 1:
		camFraction = 1
	
	var camT:Transform = _cameraRay.transform
	camT.origin = camT.origin + (fullDiff * camFraction)
	_cameraDebug = "Frac: " + str(camFraction) + " pos: " + str(camT.origin)
	_camera.transform = camT
	# _camera.transform = _thirdPersonMount.transform

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

func touch_booster(boostVelocity:Vector3) -> void:
	_vars.velocity = boostVelocity

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
		dir.z -= 1
	if Input.is_action_pressed("move_backward"):
		dir.z += 1
	if Input.is_action_pressed("move_left"):
		dir.x -= +1
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if Input.is_action_pressed("move_up"):
		dir.y += 1
	if Input.is_action_pressed("move_down"):
		dir.y -= 1
	
	# if against a surface ignore move down if it is enabled
	# if inputDir.y < 0 && _veryNearWorld.total_overlaps() > 0:
	# 	inputDir.y = 0
	
	return dir

func _apply_rotation(spatialNode:Spatial, mouse:Vector2) -> void:
	var rot:Vector3 = spatialNode.rotation_degrees
	var _invertedMul:float = 1
	# if inverted, flip yaw input
	if _head.global_transform.basis.y.dot(Vector3.UP) < 0:
		_invertedMul = -1
	rot.y += mouse.x * _invertedMul
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
	# if moving with gravity, dot will be positive
	# if moving against gravity, dot will be negative
	var dot:float = inputNormal.dot(Vector3.DOWN)
	_vars.gravityDot = dot
	var gravityStr:float = _vars.gravityStrength
	if dot == 0:
		return Vector3()
	if dot < 0:
		# if near geometry, ignore drag
		if _is_near_geometry():
			return Vector3()
		# return Vector3()
		# apply a mild drag to climbing...?
		var drag:float = gravityStr * 2
		return (Vector3.DOWN * drag * (-dot)) * _delta
	else:
		return (Vector3.DOWN * gravityStr * dot) * _delta

func _apply_move_2(inputDir:Vector3, _delta:float, _isPressingBoost:bool, isCruising:bool) -> String:
	var velocity:Vector3 = _vars.velocity

	if _isPressingBoost:
		_boostCharge += _delta
		# wipe input whilst holding boost
		#inputDir = Vector3()
	elif _boostCharge > 0:
		var weight:float = _boostCharge / _boostChargeMax
		var boostSpeed:float = 40.0 * weight
		boostSpeed = ZqfUtils.clamp_float(boostSpeed, 0.0, 40.0)
		# print("Boost: time " + str(_boostCharge) + " speed: " + str(boostSpeed))
		_boostCharge = 0
		velocity = inputDir * boostSpeed
	
	# normally speed cap is max player push...
	var speedCap:float = settings.maxPushSpeed.value
	var curSpeed:float = velocity.length()
	# ...however external pushes may override it
	if curSpeed > speedCap:
		speedCap = curSpeed
	
	inputDir = inputDir.normalized()
	_vars.pushNormal = inputDir
	# no input? apply drag
	if inputDir.length() == 0 && !isCruising:
		# increase drag as speed falls
		var mul:float = range_lerp(curSpeed, 20, 40, 0.9, 0.999999)
		if mul > 0.99:
			mul = 0.99
		velocity *= mul
	
	# good, the player hasn't fallen asleep... apply player input
	var framePush:Vector3
	if !_isPressingBoost:
		framePush = (inputDir * settings.pushStrength.value) * _delta
	else:
		# if boosting, just coast forward
		framePush = velocity.normalized() * settings.pushStrength.value
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
	var prevVelocity:Vector3 = velocity
	velocity = move_and_slide(velocity)
	if velocity != prevVelocity:
		var dot:float = velocity.normalized().dot(prevVelocity.normalized());
		# if hit is shallow, maintain speed
		if dot > 0.5:
			# print("Velocity change during move dot: " + str(dot))
			var newNormal:Vector3 = velocity.normalized()
			velocity = newNormal * prevVelocity.length()

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

func _update_body_rotation(_delta:float) -> void:
	var forward:Vector3 = _vars.velocity.normalized()
	if forward.length_squared() == 0:
		forward = -_body.global_transform.basis.z
#	var up:Vector3 = _head.global_transform.basis.y
	var up:Vector3 = _get_up()
	var origin:Vector3 = _body.global_transform.origin
	var dest:Vector3 = origin + forward
	
#	ZqfUtils.look_at_safe(_body, dest)
	_body.look_at(dest, up)

func _is_near_geometry() -> bool:
	return _nearWorld.total_overlaps() > 0

func _get_up() -> Vector3:
	var bodies = _nearWorld.get_bodies()
	var numBodies:int = bodies.size()
	if numBodies == 0:
		return Vector3.UP
	if _floorNormalRay.is_colliding():
		return _floorNormalRay.get_collision_normal()
	elif _altitudeRay.is_colliding():
		return _altitudeRay.get_collision_normal()
	else:
		return Vector3.UP

func _physics_process(_delta:float) -> void:
	# if Input.is_action_just_pressed("reset"):
	# 	_vars.velocity = Vector3()
	# 	global_transform = _spawnTransform

	#if Input.is_action_just_pressed("mode"):
	#	_vars.moveMode += 1
	#	if _vars.moveMode > 4:
	#		_vars.moveMode = 0
	
	# set body rotation			
	_apply_rotation(_head, _mouse.read_accumulator())
	_update_body_rotation(_delta)
	
	var isBoosting:bool = Input.is_action_pressed("boost")
	var isCruising:bool = Input.is_action_pressed("cruise")
	var inputPush:Vector3 = _calc_input_push(_read_move_input())
	var txt = ""
	var moveTxt = ""
	if _vars.moveMode == 2:
		moveTxt = _apply_move_2(inputPush, _delta, isBoosting, isCruising)
	else:
		_speedTrail.emitting = false
		moveTxt = _apply_debug_move(inputPush, _delta)
	pass

	# update display elements
	var _emitTrail:bool = _vars.velocity.length() > 30
	_speedTrail.emitting = _emitTrail
	_speedTrail2.emitting = _emitTrail
	_blueGlow.visible = _is_near_geometry()
	_redGlow.visible = isBoosting

	var upDot:float = _head.global_transform.basis.y.dot(Vector3.UP)
	
	if !_inputOn:
		moveTxt += "Mouse free\n"
	txt = "Mode: " + str(_vars.moveMode) + "\n" + moveTxt
	txt += "upDot: " + str(upDot) + "\n"
	txt += "Current Speed: " + str(_vars.velocity.length()) + "\n"
	txt += "World overlaps: " + str(_nearWorld.total_overlaps()) + "\n"
	txt += "Boost charge: " + str((_boostCharge / _boostChargeMax) * 100.0) + "\n"
	
	

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
	txt += _cameraDebug + "\n"
	_debugLabel.text = txt
