extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _head:Node3D = $head

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	if Zqf.has_mouse_claims():
		input_dir = Vector2()
	var direction:Vector3 = (_head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func _input(event) -> void:
	if Zqf.has_mouse_claims():
		return
	var motion:InputEventMouseMotion = event as InputEventMouseMotion
	if motion == null:
		return
	var ratio:Vector2 = ZqfUtils.get_window_to_screen_ratio()
	var degrees:Vector3 = _head.rotation_degrees
	degrees.y += (-motion.relative.x) * 0.2 * ratio.x
	var invertedMul:float = -1
	
	degrees.x += ((-motion.relative.y) * 0.2) * ratio.y * invertedMul
	degrees.x = clampf(degrees.x, -89, 89)
	_head.rotation_degrees = degrees
