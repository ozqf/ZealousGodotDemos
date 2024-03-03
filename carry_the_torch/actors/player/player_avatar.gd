extends RigidBody3D
class_name PlayerAvatar

@onready var _cameraRig:PlayerCameraRig = $camera_chaser
@onready var _debugLabel:Label3D = $surface_alignment_snap/debug_label

@onready var _groundRay:RayCast3D = $ground_ray
@onready var _downRay:RayCast3D = $display/down_ray
@onready var _surfaceSensor:Area3D = $surface_area_sensor

@onready var _surfaceSnap:Node3D = $surface_alignment_snap
@onready var _bodyMesh:Node3D = $display

enum MoveRegime { Surface, Jump, Gliding }

var _lastMoveRegime:MoveRegime = MoveRegime.Surface
var _lastSurfaceNormal:Vector3 = Vector3.UP
var _isOnSurface:bool = true
var _pitchInverted:bool = true

var _paused:bool = true

var _resetPos:Vector3 = Vector3()

func _ready():
	#ZqfUtils.disable_mouse_cursor()
	_resetPos = self.global_position
	print("Player reset pos " + str(_resetPos))
	_refresh_pause()

func calc_surface_normal(isOnSurface:bool) -> Vector3:
	if !isOnSurface:
		return _surfaceSnap.global_transform.basis.y
	if _downRay.is_colliding():
		return _downRay.get_collision_normal()
	elif _groundRay.is_colliding():
		return _groundRay.get_collision_normal()
	return _lastSurfaceNormal
	#return _cameraRig.get_floating_input_basis().y

func calc_move_regime() -> MoveRegime:
	if _isOnSurface:
		return MoveRegime.Surface
	else:
		return MoveRegime.Gliding

func _refresh_pause() -> void:
	if _paused:
		Game.add_mouse_claim(self)
	else:
		Game.remove_mouse_claim(self)

func _reset() -> void:
	_lastSurfaceNormal = Vector3.UP
	var t:Transform3D = Transform3D.IDENTITY
	t.origin = _resetPos
	self.global_transform = t
	self.linear_velocity = Vector3()
	_surfaceSnap.basis = Basis.IDENTITY
	_cameraRig.reset()

func _physics_process(_delta) -> void:
	if Input.is_action_just_pressed("pause"):
		_paused = !_paused
		_refresh_pause()
	
	if Input.is_action_just_pressed("reset"):
		_reset()
	
	var debugTxt:String = ""
	var inputOn:bool = !Game.has_mouse_claims()
	_isOnSurface = _surfaceSensor.has_overlapping_bodies()
	var regime:MoveRegime = calc_move_regime()
	if regime != _lastMoveRegime:
		print("Regime change " + str(_lastMoveRegime) + " to " + str(regime))
		_cameraRig.on_move_regime_change(_lastMoveRegime, regime)
		#if regime == MoveRegime.Surface:
		#	_cameraRig.on_glide_to_surface()
		#elif regime == MoveRegime.Glide:

	_lastMoveRegime = regime
	var pushBasis:Basis = _cameraRig.get_input_basis(_isOnSurface)
	var surfaceNormal:Vector3 = calc_surface_normal(_isOnSurface)
	var surfaceChanged:bool = !surfaceNormal.is_equal_approx(_lastSurfaceNormal)

	##################################################################################
	# orientation
	##################################################################################

	match regime:
		MoveRegime.Surface:
			if surfaceChanged:
				#print("Surface changed, " + str(_lastSurfaceNormal) + " to " + str(surfaceNormal))
				_surfaceSnap.global_transform.basis = ZqfUtils.align_to_surface(_surfaceSnap.global_transform.basis, surfaceNormal)
			_lastSurfaceNormal = surfaceNormal

			#
			_bodyMesh.global_transform.basis = _bodyMesh.global_transform.basis.orthonormalized()
			var current:Basis = _bodyMesh.global_transform.basis.orthonormalized()
			var target:Basis = current.slerp(_surfaceSnap.global_transform.basis, 0.3)

			_bodyMesh.global_transform.basis = target
			var t:Transform3D = _bodyMesh.global_transform
			var lookTarget:Vector3 = t.origin + -pushBasis.z
			_bodyMesh.look_at(lookTarget, target.y)
			_surfaceSnap.look_at(lookTarget, _lastSurfaceNormal)
			_cameraRig.set_surface_normal(surfaceNormal)

		MoveRegime.Gliding:
			_bodyMesh.look_at(_bodyMesh.global_position + -pushBasis.z, pushBasis.y)
			_surfaceSnap.look_at(_surfaceSnap.global_position + -pushBasis.z, pushBasis.y)
			#var current:Basis = _bodyMesh.global_transform.basis.orthonormalized()
			#var target:Basis = current.slerp(_surfaceSnap.global_transform.basis, 0.3)
			#var t:Transform3D = _bodyMesh.global_transform
			#var lookTarget:Vector3 = t.origin + -_cameraRig.get_floating_input_basis().z
			#_bodyMesh.look_at(lookTarget, target.y)
			#_surfaceSnap.look_at(lookTarget, _surfaceSnap.global_transform.basis.y)
	#if _isOnSurface:
	#		var lookTarget:Vector3 = t.origin + -pushBasis.z
	#		_bodyMesh.look_at(lookTarget, target.y)
	#		_surfaceSnap.look_at(lookTarget, _lastSurfaceNormal)
	#else:
	#	var lookTarget:Vector3 = t.origin + -_cameraRig.get_floating_input_basis().z
	#	_bodyMesh.look_at(lookTarget, target.y)
	#	_surfaceSnap.look_at(lookTarget, _surfaceSnap.global_transform.basis.y)
	
	# align camera
	
	##################################################################################
	# input and movement
	##################################################################################
	# input to world push direction
	var axisX:float = Input.get_axis("move_left", "move_right")
	var axisZ:float = Input.get_axis("move_forward", "move_backward")
	var moveUp:bool = Input.is_action_pressed("move_up")
	var moveDown:bool = Input.is_action_pressed("move_down")
	var inputDir:Vector2 = Vector2(axisX, axisZ)
	if !inputOn:
		moveUp = false
		moveDown = false
		inputDir = Vector2.ZERO
	var pushDir:Vector3 = ZqfUtils.input_to_push_vector_flat(inputDir, pushBasis)
	var prevVelocity:Vector3 = self.linear_velocity
	var prevSpeed:float = self.linear_velocity.length()
	
	# calc push strength
	var pushStr:float = 120 if _isOnSurface else 60
	var pushToApply:Vector3 = (pushDir * pushStr)
	# scale by dot product and range to maximum
	var maxSpeed:float = 40.0
	var speedWeight:float = prevSpeed / maxSpeed
	
	if inputDir.is_equal_approx(Vector2.ZERO):
		speedWeight = 1.0
	
	var drag:Vector3 = Vector3.ZERO
	
	if true: #_isOnSurface:
		var drag1:Vector3 = -pushToApply * speedWeight
		var drag2:Vector3 = (-prevVelocity.normalized()) * pushToApply.length() * speedWeight
		drag = drag2
	
	var newVelocity:Vector3 = prevVelocity + (pushToApply * _delta) + (drag * _delta)
	
	if _isOnSurface:
		if moveUp:
			newVelocity += surfaceNormal * 10
		# if the player is not on flat ground, pull them onto the surface slightly
		# otherwise they can drift off
		if surfaceNormal.dot(Vector3.UP) != 1:
			newVelocity += (-surfaceNormal) * 5 * _delta
	#else:
	#	# apply regular gravity
	#	if !moveDown:
	#		newVelocity.y += (-5 * _delta)
	
	self.linear_velocity = newVelocity
	
	# debug text
	debugTxt += str(prevSpeed) + "m/s\n"
	debugTxt += "Speed % " + str(speedWeight) + "\n"
	debugTxt += "On Surface: " + str(_isOnSurface) + "\n"
	if _downRay.is_colliding():
		debugTxt += "Down: " + str(_downRay.get_collision_normal()) + "\n"
	else:
		debugTxt += "Down - no collision\n"
	if _groundRay.is_colliding():
		debugTxt += "Ground: " + str(_groundRay.get_collision_normal()) + "\n"
	else:
		debugTxt += "Ground - no collision\n"
	debugTxt += "Surface: " + str(surfaceNormal) + "\n"
	_debugLabel.text = debugTxt

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
	
	if _isOnSurface:
		_cameraRig.apply_surface_yaw(degreesYaw)
		_cameraRig.apply_surface_pitch(degreesPitch)
	else:
		_cameraRig.apply_gliding_pitch(degreesPitch)
		_cameraRig.apply_gliding_roll(degreesYaw)
		#if Input.is_action_pressed("move_down"):
		#	#_surfaceSnap.rotate(_surfaceSnap.basis.z, degreesYaw * ZqfUtils.DEG2RAD)
		#	#_surfaceSnap.rotate(_surfaceSnap.basis.x, degreesPitch * ZqfUtils.DEG2RAD)
		#	_cameraRig.apply_surface_pitch(degreesPitch)
		#	_cameraRig.apply_gliding_roll(degreesYaw)
		#else:
		#	_cameraRig.apply_surface_yaw(degreesYaw)
		#	_cameraRig.apply_surface_pitch(degreesPitch)
	#_cameraRig.on_input(event)
