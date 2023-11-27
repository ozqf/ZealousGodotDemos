extends CharacterBody3D

@onready var _bodyShape:CollisionShape3D = $CollisionShape3D
@onready var _display:Node3D = $model
@onready var _meleePods = $melee_pods
@onready var _gunPods = $gun_pods

var _meleeMode:bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func activate(resumeVelocity:Vector3, meleeMode:bool = true) -> void:
	_meleeMode = meleeMode
	_bodyShape.disabled = false
	_display.visible = true
	self.velocity = resumeVelocity

func deactivate() -> void:
	_bodyShape.disabled = true
	_display.visible = false

func get_right_fist() -> Node3D:
	return _meleePods.get_right_fist()

func get_left_fist() -> Node3D:
	return _meleePods.get_left_fist()

func get_right_gun() -> Node3D:
	return _gunPods.get_right()

func get_left_gun() -> Node3D:
	return _gunPods.get_left()

func input_process(_input:PlayerInput, _delta:float) -> void:
	_meleePods.update_yaw(_input.yaw)
	_gunPods.update_yaw(_input.yaw)
	_gunPods.update_aim_point(_input.aimPoint) 

func input_physics_process(_input:PlayerInput, _delta:float) -> void:
	var pushDir:Vector3 = _input.pushDir
	#if _meleePods.is_attacking():
	#	pushDir = Vector3()
	var curVelocity:Vector3 = self.velocity
	var curSpeed:float = self.velocity.length()

	if self.is_on_floor():
		if curSpeed > 8 || pushDir.is_zero_approx():
			curSpeed *= 0.85
			curVelocity = curVelocity.limit_length(curSpeed)
		#elif _meleePods.is_attacking():
		#	curSpeed *= 0.7
	
	var pushStr:float = 80.0
	if !self.is_on_floor():
		pushStr = 10.0
	elif _meleePods.is_attacking():
		pushStr = 5.0
	curVelocity += pushDir * pushStr * _delta

	curVelocity += Vector3(0, -gravity, 0) * _delta
	
	if self.is_on_floor():
		if Input.is_action_just_pressed("move_up"):
			curVelocity.y = 10.0
	
	# moves cancel vertical movement!
	if _meleeMode:
		if _input.attack1:
			if _meleePods.jab() && !self.is_on_floor():
				curVelocity.y = 4.0


	
	self.velocity = curVelocity

	self.move_and_slide()

