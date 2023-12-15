extends RigidBody3D
class_name PlayerAvatarBall

signal avatar_event(sourceNode, evType, dataObj)

const SPEED:float = 5.0
const MAX_PUSH_STR:float = 25.0
const MAX_NO_DRAG_SPEED:float = 20.0
const MAX_SPEED:float = 30.0

# @onready var _bodyTracker:Node3D = $tracker
# @onready var _head:Node3D = $tracker/head
# @onready var _aimRay:RayCast3D = $tracker/head/camera_mount/RayCast3D
#@onready var _aimDot:Node3D = $aim_dot
@onready var _groundSensor:Area3D = $ground_detector
@onready var _bodyShape:CollisionShape3D = $CollisionShape3D

enum Stance { Spawning, Ball, Melee }

var _stance:Stance = Stance.Ball

var _meleeVelocity:Vector3 = Vector3()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func teleport(_transform:Transform3D) -> void:
	self.emit_signal("avatar_event", self, Game.AVATAR_EVENT_TYPE_TELEPORT, _transform)
	self.linear_velocity = Vector3()
	self.angular_velocity = Vector3()

func is_grounded() -> bool:
	return _groundSensor.has_overlapping_bodies() || _groundSensor.has_overlapping_areas()

func get_velocity() -> Vector3:
	return self.linear_velocity

func activate(resumeVelocity:Vector3) -> void:
	self.freeze = false
	_bodyShape.disabled = false
	self.visible = true
	linear_velocity = resumeVelocity
	pass

func deactivate() -> void:
	self.freeze = true
	_bodyShape.disabled = true
	self.visible = false
	pass

func _change_stance(newStance:Stance) -> void:
	_stance = newStance
	if _stance == Stance.Ball:
		self.freeze = false
	elif _stance == Stance.Melee:
		_meleeVelocity = self.linear_velocity
		self.freeze = true

func _process(_delta):
	# var origin:Vector3 = _bodyTracker.global_position
	var target:Vector3 = self.global_position
	# var dest:Vector3 = origin.lerp(target, 0.9)
	# _bodyTracker.global_position = dest
	
	# if _aimRay.is_colliding():
	# 	_aimDot.global_position = _aimRay.get_collision_point()
	
	var footPos:Vector3 = target + Vector3(0, -0.5, 0)
	_groundSensor.global_position = footPos
	
	_groundSensor.visible = is_grounded()

func input_physics_process(_input:PlayerInput, _delta:float) -> void:
	#var head:Vector3 = _bodyTracker.global_position
	#var pos:Vector3 = self.global_position
	#var towardHead:Vector3 = (head - pos).normalized()
	#towardHead.y = 1.0
	var dir:Vector3 = _input.pushDir
	#var pos:Vector3 = self.global_position
	# var offset:Vector3 = -dir
	
	#var offset:Vector3 = (_input.camera.basis.z + _input.camera.basis.y)
	#var offset:Vector3 = (-_input.camera.basis.z)
	var offset:Vector3 = Vector3.ZERO
	
	var speed:float = self.linear_velocity.length()
	var pushStr:float = MAX_PUSH_STR
	if speed > 999999: #MAX_NO_DRAG_SPEED:
		var maxSpeedWeight:float = clampf(speed - MAX_NO_DRAG_SPEED / MAX_SPEED - MAX_NO_DRAG_SPEED, 0, 1)
		# flip it, so the further from max we are the higher the scaler
		maxSpeedWeight = 1 - maxSpeedWeight
		var againstCurrentDotP:float = dir.dot(self.linear_velocity.normalized())
		#againstCurrentDotP = absf(againstCurrentDotP)
		if againstCurrentDotP > 0:
			pushStr = maxSpeedWeight * againstCurrentDotP
		elif againstCurrentDotP < 0:
			pass
		else:
			pass
		#print("Speed " + str(speed) + " Against dp " + str(againstCurrentDotP) + " Max speed weight " + str(maxSpeedWeight) + " push str " + str(pushStr))
	dir *= pushStr
	self.apply_force(dir, offset)

	if _input.hookState == HookShot.STATE_GRAPPLE_POINT:
		var toward:Vector3 = _input.hookPosition - self.global_position
		var dist:float = toward.length()
		toward = toward.normalized()
		var weight:float = dist / 40.0
		var strength:float = lerp(0, 100, clampf(weight, 0, 1))
		# constrain movement to length of rope
		#var currentForward:Vector3 = self.linear_velocity.normalized()
		#var towardForwardDot:float = toward.normalized().dot(currentForward)
		#print("Toward dot " + str(towardForwardDot))
		#if towardForwardDot < 0.0:
		#	var limited:Vector3 = self.linear_velocity * towardForwardDot
		#	var v:Vector3 = self.linear_velocity - limited
		#	self.linear_velocity = v
		self.linear_velocity += toward * strength * _delta

	if is_grounded() && Input.is_action_just_pressed("move_up"):
		self.linear_velocity.y = 10.0
	pass

func physics_process_ball(_delta:float) -> void:
	# var input_dir:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	# #var velocity:Vector3 = Vector3()
	
	# if Zqf.has_mouse_claims():
	# 	input_dir = Vector2()
	# var direction:Vector3 = (_bodyTracker.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# if direction:
	# 	apply_custom_push(direction)
	pass

# func _physics_process_melee(_delta:float) -> void:
# 	var input_dir:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
# 	var velocity:Vector3 = Vector3()
	
# 	if Zqf.has_mouse_claims():
# 		input_dir = Vector2()
# 	var direction:Vector3 = (_bodyTracker.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
# 	if direction:
# 		_meleeVelocity += direction * 20.0
# 	else:
# 		_meleeVelocity *= 0.9
	
# 	var speedCap:float = 8.0
# 	var speed:float = _meleeVelocity.length()
	
# 	_meleeVelocity = _meleeVelocity.limit_length(speedCap)
	
# 	if !is_grounded():
# 		_meleeVelocity += (Vector3(0, -gravity, 0) * _delta)
	
# 	var move:Vector3 = _meleeVelocity * _delta
# 	self.move_and_collide(move)
# 	print("Speed: " + str(_meleeVelocity.length()) + " Velocity: " + str(_meleeVelocity) + " Grounded: " + str(is_grounded()))

# func _physics_process(delta):
	
# 	if Input.is_action_just_pressed("character_stance"):
# 		if _stance == Stance.Melee:
# 			_change_stance(Stance.Ball)
# 		elif _stance == Stance.Ball:
# 			_change_stance(Stance.Melee)
# 		pass
	
# 	match _stance:
# 		Stance.Ball:
# 			physics_process_ball(delta)
# 		Stance.Melee:
# 			_physics_process_melee(delta)

# func teleport(_t:Transform3D) -> void:
# 	_t.origin.y += 0.5
# 	self.global_transform = _t

# func _input(event) -> void:
# 	if Zqf.has_mouse_claims():
# 		return
# 	var motion:InputEventMouseMotion = event as InputEventMouseMotion
# 	if motion == null:
# 		return
# 	var degrees:Vector3 = _bodyTracker.rotation_degrees
# 	degrees.y += (-motion.relative.x) * 0.1
# 	_bodyTracker.rotation_degrees = degrees
	
# 	degrees = _head.rotation_degrees
# 	degrees.x += (motion.relative.y) * 0.1
# 	_head.rotation_degrees = degrees
