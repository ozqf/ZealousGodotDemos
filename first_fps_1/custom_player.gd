extends CharacterBody3D

const RUN_SPEED = 10.0
const ACCELERATION_GROUND:float = 200
const ACCELERATION_AIR:float = 25
const JUMP_SPEED:float = 10
const FRICTION_FLOOR:float = 0.9
const MOUSE_RELATIVE_SENSITIVITY:float = 0.003

@onready var _head:Node3D = $head

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	var inputDir:Vector3 = Vector3()
	inputDir.x = Input.get_axis("move_left", "move_right")
	inputDir.y = Input.get_axis("move_down", "move_up")
	inputDir.z = Input.get_axis("move_forward", "move_backward")
	
	# horizontal movement (X and Z)
	# translate input axes to axes of object
	var rot:Basis = global_transform.basis
	var pushDir:Vector3 = Vector3()
	pushDir += inputDir.x * rot.x
	pushDir += inputDir.z * rot.z
	pushDir = pushDir.normalized()
	
	# separate out horizontal component of velocity, calculate it
	# and apply it back. Y is handled independently
	var horizontal:Vector3 = velocity
	horizontal.y = 0
	
	# friction if the player is not pushing, or their push i
	if pushDir == Vector3.ZERO:
		if is_on_floor():
			horizontal = horizontal * FRICTION_FLOOR
	else:
		var pushStrength:float = ACCELERATION_GROUND
		if !is_on_floor():
			pushStrength = ACCELERATION_AIR
		horizontal += pushDir * pushStrength * delta
	
	# cap horizontal speed
	horizontal = horizontal.limit_length(RUN_SPEED)
	
	# apply new hoizontal motion back to velocity
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	
	# vertical
	if is_on_floor():
		if inputDir.y > 0:
			velocity.y = 10.0
	else:
		velocity += Vector3(0, -_gravity, 0) * delta
	
	# do
	move_and_slide()

func _input(event):
	var motion:InputEventMouseMotion = event as InputEventMouseMotion
	if motion == null:
		return
	
	var yawRadians:float = -motion.relative.x * MOUSE_RELATIVE_SENSITIVITY
	self.rotate(Vector3.UP, yawRadians)
	
	var pitchRadians:float = motion.relative.y * MOUSE_RELATIVE_SENSITIVITY
	_head.rotate(Vector3.RIGHT, pitchRadians)
