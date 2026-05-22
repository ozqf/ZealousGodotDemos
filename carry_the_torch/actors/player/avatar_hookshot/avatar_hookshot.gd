extends CharacterBody3D
class_name AvatarHookshot

@onready var _yawNode:Node3D = $yaw
@onready var _pitchNode:Node3D = $yaw/pitch
@onready var _hookRay:RayCast3D = $yaw/pitch/Camera3D/RayCast3D
@onready var _plyrInput:PlayerInput = $PlayerInput
@onready var _hookWidget:Node3D = $hook_widget
@onready var _ropeMesh:Node3D = $rope_mesh

@export var gravity: float = 20.0 # 9.8
@export var reel_speed: float = 1.0
@export var swing_push_force: float = 15.0
@export var max_speed: float = 30.0 # Maximum allowed velocity magnitude

@export_range(0.0, 500.0, 0.5) var elasticity: float = 0.0 # 0 = Completely rigid, >0 = Bungee spring stiffness
@export var spring_damping: float = 2.0 # Prevents infinite, uncontrolled bouncing

var is_attached: bool = false
var pivot_point: Vector3 = Vector3.ZERO
var rope_length: float = 0.0

@onready var camera: Camera3D = $yaw/pitch/Camera3D 

func _input(inputEv:InputEvent) -> void:
	var motion:InputEventMouseMotion = inputEv as InputEventMouseMotion
	if motion == null:
		return
	var scalar:float = 0.002
	var sensitivity:float = 1.0
	var diffYaw:float = motion.relative.x * scalar * sensitivity
	_yawNode.rotate(_yawNode.basis.y, -diffYaw)
	var diffPitch:float = motion.relative.y * scalar * sensitivity
	_pitchNode.rotate(_pitchNode.basis.x, diffPitch)

func attach_rope(target_pivot: Vector3) -> void:
	pivot_point = target_pivot
	rope_length = global_position.distance_to(pivot_point)
	is_attached = true

func detach_rope() -> void:
	is_attached = false

func move_to(current: float, target: float, step: float) -> float:
	return current + clamp(target - current, -step, step)

#region move_logic


func _process(delta: float) -> void:
	var input_vector = _plyrInput.get_push_v3()
	
	if Input.is_action_just_pressed("action_1"):
		if not is_attached:
			if _hookRay.is_colliding():
				var target = _hookRay.get_collision_point() # global_position + (-camera.global_transform.basis.z * 5.0) + Vector3(0, 15, 0)
				print("Attach to " + str(target))
				attach_rope(target)
		else:
			detach_rope()
	
	_ropeMesh.visible = is_attached
	if is_attached:
		_hookWidget.visible = true
		_ropeMesh.look_at(pivot_point)
		_hookWidget.global_position = pivot_point
		var s:Vector3 = Vector3(1, 1, _ropeMesh.global_position.distance_to(pivot_point))
		_ropeMesh.scale = s
		handle_swing_physics(input_vector, delta)
	else:
		if _hookRay.is_colliding():
			_hookWidget.visible = true
			_hookWidget.global_position = _hookRay.get_collision_point()
		else:
			_hookWidget.visible = false
		handle_free_movement(input_vector, delta)

func handle_swing_physics(input_vector: Vector3, delta: float) -> void:
	# 1. Base gravity
	velocity.y -= gravity * delta

	var to_player = global_position - pivot_point
	var current_distance = to_player.length()
	var rope_direction = to_player.normalized()

	# 2. Handle Reeling (Y Input)
	var reel_input = input_vector.y
	if reel_input != 0.0:
		var length_change = reel_input * reel_speed * delta
		rope_length += length_change
		rope_length = max(rope_length, 1.5)
		
		if length_change < 0.0:
			velocity += rope_direction * (length_change / delta)

	# 3. Handle First-Person Push Force
	var cam_basis = camera.global_transform.basis
	var push_direction = (cam_basis.x * input_vector.x) + (cam_basis.z * input_vector.z)
	
	if push_direction.length() > 0.0:
		push_direction = push_direction.normalized()
		var push_along_rope = push_direction.dot(rope_direction)
		var valid_swing_push = push_direction - (rope_direction * push_along_rope)
		
		velocity += valid_swing_push * swing_push_force * delta

	# 4. Enforce Rope Constraint (Rigid vs Elastic)
	if current_distance > rope_length:
		if elasticity == 0.0:
			# --- RIGID ROPE LOGIC ---
			global_position = pivot_point + (rope_direction * rope_length)
			var vel_along_rope = velocity.dot(rope_direction)
			if vel_along_rope > 0.0:
				velocity -= rope_direction * vel_along_rope
		else:
			# --- ELASTIC ROPE LOGIC (Hooke's Law) ---
			var stretch = current_distance - rope_length
			
			# Calculate spring pull force vector
			var spring_force_magnitude = stretch * elasticity
			var spring_force = -rope_direction * spring_force_magnitude
			
			# Calculate damping force along the rope to eliminate endless micro-jitter
			var vel_along_rope = velocity.dot(rope_direction)
			var damping_force = -rope_direction * (vel_along_rope * spring_damping)
			
			# Apply total spring vector accelerations
			velocity += (spring_force + damping_force) * delta

	# 5. Clamp Speed to Maximum Parameter limit
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	move_and_slide()

func handle_free_movement(input_vector: Vector3, delta: float) -> void:
	velocity.y -= gravity * delta
	var cam_basis = camera.global_transform.basis
	var move_dir = (cam_basis.x * input_vector.x) + (cam_basis.z * input_vector.z)
	move_dir.y = 0 
	
	if move_dir.length() > 0.0:
		move_dir = move_dir.normalized()
		velocity.x = move_dir.x * 10.0
		velocity.z = move_dir.z * 10.0
	else:
		velocity.x = move_to(velocity.x, 0.0, 15.0 * delta)
		velocity.z = move_to(velocity.z, 0.0, 15.0 * delta)
		
	# Clamp free-movement speed just in case player detached at high speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
		
	move_and_slide()



#endregion
