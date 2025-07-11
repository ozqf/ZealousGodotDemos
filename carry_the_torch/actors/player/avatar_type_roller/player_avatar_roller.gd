extends RigidBody3D

@onready var _playerInput:PlayerInput = $PlayerInput
@onready var _cameraRig:Node3D = $camera_rig
@onready var _pushRig:Node3D = $flat_push_rig
@onready var _debugLabel:Label3D = $camera_rig/debug_label

var _pitchInverted:bool = true
var _isOnSurface:bool = true

func _ready() -> void:
	print("Roller Avatar type spawned")

func _process(_delta: float) -> void:
	var lerpWeight:float = 0.9
	var turnRadiansPerSecond:float = 360 * ZqfUtils.DEG2RAD
	var yaw:float = _playerInput.lookKeys.x
	var t:Transform3D = _cameraRig.global_transform
	_cameraRig.rotate(t.basis.y, yaw * _delta * turnRadiansPerSecond)
	_pushRig.rotate(_pushRig.global_transform.basis.y, yaw * _delta * turnRadiansPerSecond)
	
	var camPos:Vector3 = _cameraRig.global_position
	var selfPos:Vector3 = self.global_position
	camPos = camPos.lerp(selfPos, lerpWeight)
	_cameraRig.global_position = camPos
	
	_pushRig.global_position = _pushRig.global_position.lerp(selfPos, lerpWeight)
	pass

func _physics_process(_delta) -> void:
	_platformer_move(_delta)

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
	
	var contactCount:int = self.get_contact_count()
	self.get_colliding_bodies()
	txt += str(contactCount) + " Contacts\n"
	txt += str(contact_points.size()) + " contact points\n"
	_debugLabel.text = txt

var contact_points = []

func _integrate_forces(state:PhysicsDirectBodyState3D) -> void:
	var contact_count = state.get_contact_count()
	contact_points.clear()
	var txt = "";
	for i in range(contact_count):
		var normal:Vector3 = state.get_contact_local_normal(i)
		txt += str(normal) + ", "
		#var local_contact_position = state.get_contact_local_position(i)
		#var global_contact_position = to_global(local_contact_position)
		#contact_points.append(global_contact_position)
		#print("Contact point ", i, ": Local = ", local_contact_position, ", Global = ", global_contact_position)
	if txt != "":
		print(txt)

func _integrate_forces_example(state:PhysicsDirectBodyState3D) -> void:
	var contact_count = state.get_contact_count()
	contact_points.clear()
	for i in range(contact_count):
		var local_contact_position = state.get_contact_local_position(i)
		var global_contact_position = to_global(local_contact_position)
		contact_points.append(global_contact_position)
		print("Contact point ", i, ": Local = ", local_contact_position, ", Global = ", global_contact_position)

	# Example: Accessing contact points outside of _integrate_forces
	if contact_points.size() > 0:
		print("First contact point: ", contact_points[0])

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
	
	var rot:Vector3 = _cameraRig.rotation_degrees
	rot.x += degreesPitch
	rot.y += degreesYaw
	_cameraRig.rotation_degrees = rot
	
	rot = _pushRig.rotation_degrees
	rot.y += degreesYaw
	_pushRig.rotation_degrees = rot
