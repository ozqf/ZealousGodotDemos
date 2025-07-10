extends RigidBody3D

@onready var _wheel:Node3D = $wheel
@onready var _playerInput:PlayerInput = $PlayerInput
@onready var _cameraRig:Node3D = $camera_rig
@onready var _pushRig:Node3D = $flat_push_rig
@onready var _debugLabel:Label3D = $camera_rig/debug_label

var _pitchInverted:bool = true
var _isOnSurface:bool = true

func _ready() -> void:
	print("Roller Avatar type spawned")

func _process(_delta: float) -> void:
	# keyboard turn
	var turnRadiansPerSecond:float = 360 * ZqfUtils.DEG2RAD
	var yaw:float = _playerInput.lookKeys.x
	var t:Transform3D = _cameraRig.global_transform
	var yawDegrees:float = yaw * _delta * (turnRadiansPerSecond * ZqfUtils.RAD2DEG)
	_apply_rotation(yawDegrees, 0)
	
	# lerp camera to avatar
	var lerpWeight:float = 0.9
	var camPos:Vector3 = _cameraRig.global_position
	var selfPos:Vector3 = self.global_position
	camPos = camPos.lerp(selfPos, lerpWeight)
	_cameraRig.global_position = camPos
	
	_pushRig.global_position = _pushRig.global_position.lerp(selfPos, lerpWeight)

func _apply_rotation(degreesYaw:float, degreesPitch:float) -> void:
	var rot:Vector3 = _cameraRig.rotation_degrees
	rot.x += degreesPitch
	rot.y += degreesYaw
	_cameraRig.rotation_degrees = rot
	
	rot = _pushRig.rotation_degrees
	rot.y += degreesYaw
	_pushRig.rotation_degrees = rot

func _input(event) -> void:
	if Game.has_mouse_claims():
		return
	var motion:InputEventMouseMotion = event as InputEventMouseMotion
	if motion == null:
		return
	
	var degreesYaw:float = (-motion.relative.x) * 0.2
	var degreesPitch:float = (-motion.relative.y) * 0.2
	# inverted?
	if _pitchInverted:
		degreesPitch = -degreesPitch
	_apply_rotation(degreesYaw, degreesPitch)

func _physics_process(_delta) -> void:
	_wheel_move(_delta)

func _wheel_move(_delta:float) -> void:
	var accelInput:float = -_playerInput.inputDir.y
	#var pushInput:Vector3 = Vector3(_playerInput.inputDir.x, 0, _playerInput.inputDir.y)
	var pushForward:Vector3 = -_pushRig.global_transform.basis.z
	var pushTransverse:Vector3 = _pushRig.global_transform.basis.x
	
	var forward:Vector3 = -_wheel.global_transform.basis.z
	var forwardTransverse:Vector3 = _wheel.global_transform.basis.x
	
	var reverseDot:float = forward.dot(pushForward)
	var turnDot:float = forward.dot(pushTransverse)
	
	var accelMetresPerSecond:float = 60.0
	var maxTurnRateDegrees:float = 180.0
	var turnToLeft:bool = true if turnDot > 0.0 else false
	
	var v:Vector3 = self.linear_velocity
	var flatV:Vector3 = Vector3(v.x, 0.0, v.y)
	
	if !flatV.is_zero_approx():
		if turnToLeft:
			_wheel.rotate(Vector3.UP, maxTurnRateDegrees * ZqfUtils.DEG2RAD * _delta)
		else:
			_wheel.rotate(Vector3.UP, -maxTurnRateDegrees * ZqfUtils.DEG2RAD * _delta)
	
	var push:Vector3 = (forward * accelInput) * accelMetresPerSecond * _delta
	v += push
	
	self.linear_velocity = v
	
	var txt:String = str(accelInput) + " accel input\n"
	txt += str(push) + " push\n"
	txt += str(turnDot) + " turn dot\n"
	txt += str(reverseDot) + " reverse dot\n"
	#txt += str(flatV) + " flat vel\n"
	txt += str(v) + " vel\n"
	_debugLabel.text = txt

func _platformer_move(_delta) -> void:
	#var t:Transform3D = self.global_transform
	var t:Transform3D = _pushRig.global_transform
	
	var flatForward:Vector3
	# var _pushDirection:Vector3 = (basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	#var pushDir:Vector3 = ZqfUtils.input_to_push_vector_flat(_input.inputDir, t.basis)
	var pushInput:Vector3 = Vector3(_playerInput.inputDir.x, 0, _playerInput.inputDir.y)
	var pushDir:Vector3 = (t.basis * pushInput).normalized()
	pushDir *= 35.0
	var v:Vector3 = self.linear_velocity
	var flatV:Vector3 = Vector3(v.x, 0.0, v.y)
	v.x += pushDir.x * _delta
	v.y += -20.0 * _delta
	v.z += pushDir.z * _delta
	self.linear_velocity = v
	
	var txt:String = str(pushInput) + "\n"
	txt += str(self.linear_velocity) + "\n"
	txt += str(self.angular_velocity) + "\n"
	_debugLabel.text = txt

func _angular_momentum_push(_delta:float) -> void:
	var pushInput:Vector3 = Vector3(_playerInput.inputDir.x, 0, _playerInput.inputDir.y)
	var av:Vector3 = self.angular_velocity
	
	var accelPush:float = (_playerInput.inputDir.y) * 50.0 * _delta
	av.x += accelPush
	self.angular_velocity = av
	
	var txt:String = str(pushInput) + "\n"
	txt += str(self.linear_velocity) + "\n"
	txt += str(self.angular_velocity) + "\n"
	_debugLabel.text = txt
