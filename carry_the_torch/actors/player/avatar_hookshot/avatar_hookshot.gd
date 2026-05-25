extends CharacterBody3D
class_name AvatarHookshot

@onready var _yawNode:Node3D = $yaw
@onready var _pitchNode:Node3D = $yaw/pitch
@onready var _hookRay:RayCast3D = $yaw/pitch/Camera3D/RayCast3D
@onready var _plyrInput:PlayerInput = $PlayerInput
@onready var _hookWidget:Node3D = $hook_widget
@onready var _ropeMesh:Node3D = $rope_mesh
@onready var _ropeMeshAlt:MeshInstance3D = $rope_mesh_alt

@export var gravity: float = 20.0 # 9.8
@export var reel_speed: float = 1.0
@export var swing_push_force: float = 15.0
@export var max_speed: float = 30.0 # Maximum allowed velocity magnitude

@export var soft_max_speed: float = 20.0 # Limit for player-driven push/reel speed
@export var hard_max_speed: float = 45.0 # Absolute safety limit for external forces (fans, springs)
@export var min_rope_length:float = 1.5
@export var max_rope_length:float = 40.0

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

#region immediate mesh draw

func update_rope_visual(rope_renderer:MeshInstance3D, start_pos: Vector3, end_pos: Vector3, rope_color: Color, active: bool) -> void:
	# 1. Access the ImmediateMesh resource from your MeshInstance3D node
	var imm_mesh: ImmediateMesh = rope_renderer.mesh as ImmediateMesh
	if imm_mesh == null:
		return
	
	# 2. Always clear the previous frame's drawing first
	imm_mesh.clear_surfaces()
	
	# 3. If the rope isn't currently attached, stop here and leave it empty
	if not active:
		return
		
	# 4. Create a basic unshaded material color if the mesh doesn't have one
	if rope_renderer.material_override == null:
		var mat = ORMMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.vertex_color_use_as_albedo = true
		rope_renderer.material_override = mat

	# 5. ImmediateMesh requires positions to be in its local coordinate space.
	# We convert the world-space anchor point to the renderer's local space.
	var local_start = rope_renderer.to_local(start_pos)
	var local_end = rope_renderer.to_local(end_pos)

	# 6. Begin drawing a line strip primitive surface
	imm_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	# Set line start point attributes
	imm_mesh.surface_set_color(rope_color)
	imm_mesh.surface_add_vertex(local_start)
	
	# Set line end point attributes
	imm_mesh.surface_set_color(rope_color)
	imm_mesh.surface_add_vertex(local_end)
	
	# Finalise the surface generation loop
	imm_mesh.surface_end()
	
#endregion

#region move_logic

func _process(delta:float) -> void:
	_process_movement(delta)
	update_rope_visual(_ropeMeshAlt, self.global_position, pivot_point, Color.RED, is_attached)

func _process_movement(delta: float) -> void:
	var input_vector = _plyrInput.get_push_v3()
	
	if Input.is_action_just_pressed("action_1"):
		if not is_attached:
			if _hookRay.is_colliding():
				var target = _hookRay.get_collision_point() # global_position + (-camera.global_transform.basis.z * 5.0) + Vector3(0, 15, 0)
				print("Attach to " + str(target))
				attach_rope(target)
		else:
			detach_rope()
	
	#_ropeMesh.visible = is_attached
	_ropeMesh.visible = false
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
	# 1. Base gravity environment acceleration
	velocity.y -= gravity * delta

	var to_player = global_position - pivot_point
	var current_distance = to_player.length()
	var rope_direction = to_player.normalized()

	# 2. Reeling
	var reel_input = input_vector.y
	if reel_input != 0.0:
		# Shift the target structural length of the rope
		var length_change = reel_input * reel_speed * delta
		rope_length += length_change
		rope_length = clamp(rope_length, min_rope_length, max_rope_length)

		# Soft Cap Check: Cleanly inject climbing velocity along the rope direction
		if velocity.length() < soft_max_speed:
			var climb_velocity = rope_direction * (length_change / delta)
			var projected_velocity = velocity + climb_velocity
			
			if projected_velocity.length() > soft_max_speed:
				velocity = projected_velocity.normalized() * soft_max_speed
			else:
				velocity += climb_velocity

	# 3. Handle First-Person Horizontal Push Force
	var cam_basis = camera.global_transform.basis
	var push_direction = (cam_basis.x * input_vector.x) + (cam_basis.z * input_vector.z)
	
	if push_direction.length() > 0.0:
		push_direction = push_direction.normalized()
		var push_along_rope = push_direction.dot(rope_direction)
		var valid_swing_push = push_direction - (rope_direction * push_along_rope)
		
		if velocity.length() < soft_max_speed:
			var push_acceleration = valid_swing_push * swing_push_force * delta
			var projected_velocity = velocity + push_acceleration
			
			if projected_velocity.length() > soft_max_speed:
				velocity = projected_velocity.normalized() * soft_max_speed
			else:
				velocity += push_acceleration

	# 4. Enforce Fixed Boundary Constraint (Rigid vs Elastic)
	# Recalculate distance after applying player inputs to see if we cross the rope boundary
	var expected_next_distance = (global_position + velocity * delta - pivot_point).length()
	
	if expected_next_distance >= rope_length:
		if elasticity == 0.0:
			# --- FIXED RIGID LOCK ---
			# First, strip away any velocity vectors pushing outward past the rope radius
			var vel_along_rope = velocity.dot(rope_direction)
			if vel_along_rope > 0.0:
				velocity -= rope_direction * vel_along_rope
			
			# If the player is currently outside the rope boundaries (due to past frames or reeling changes),
			# inject a correction velocity to firmly snap them back onto the radius surface this frame.
			if current_distance > rope_length:
				var correction_distance = current_distance - rope_length
				velocity -= rope_direction * (correction_distance / delta)
		else:
			# --- ELASTIC ROPE ---
			var stretch = current_distance - rope_length
			if stretch > 0.0:
				var spring_force_magnitude = stretch * elasticity
				var spring_force = -rope_direction * spring_force_magnitude
				
				var vel_along_rope = velocity.dot(rope_direction)
				var damping_force = -rope_direction * (vel_along_rope * spring_damping)
				
				velocity += (spring_force + damping_force) * delta

	# 5. Hard Cap enforcement
	if velocity.length() > hard_max_speed:
		velocity = velocity.normalized() * hard_max_speed

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
