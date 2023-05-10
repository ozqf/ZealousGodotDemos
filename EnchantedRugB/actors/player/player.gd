extends CharacterBody3D

const SPEED = 10.0
const JUMP_VELOCITY = 4.5

@onready var _head:Node3D = $head

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# attack
var _prjBasicType = preload("res://projectiles/basic/prj_basic.tscn")
@onready var _attackTimer:Timer = $attack_timer

func _physics_process_default(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _physics_process(_delta:float) -> void:
	_tick_movement(_delta)
	_tick_attack(_delta)

func _tick_movement(_delta:float) -> void:
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

func teleport(t:Transform3D) -> void:
	self.global_position = t.origin

func _input(event) -> void:
	if Zqf.has_mouse_claims():
		return
	var motion:InputEventMouseMotion = event as InputEventMouseMotion
	if motion == null:
		return
	var degrees:Vector3 = _head.rotation_degrees
	degrees.y += (-motion.relative.x) * 0.1
	_head.rotation_degrees = degrees

######################################################
# Attack
######################################################

func _fire_projectile(node:Node3D, typeObj) -> void:
	var prj = typeObj.instantiate()
	Zqf.get_actor_root().add_child(prj)
	prj.launch(node.global_position, -node.global_transform.basis.z)

func _tick_attack(_delta:float) -> void:
	if Zqf.has_mouse_claims():
		return
	if !_attackTimer.is_stopped():
		return
	if Input.is_action_pressed("attack_1"):
		_attackTimer.one_shot = true
		_attackTimer.wait_time = 0.1
		_attackTimer.start()
		_fire_projectile(_head, _prjBasicType)
