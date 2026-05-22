extends Node3D

const STATE_NONE:int = 0
const STATE_RUNNING:int = 1
const STATE_APPLY_COLLAPSE:int = 2

@onready var _debrisChild:Node3D = $debris_burst
@onready var _character:CharacterBody3D = $CharacterBody3D

var _state:int = STATE_NONE

var _debris:Array[RigidBodyDebris] = []
var _xforms:Array[Transform3D] = []
var _ray:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()


func _ready() -> void:
	for child in _debrisChild.get_children():
		var debris:RigidBodyDebris = child as RigidBodyDebris
		if debris == null:
			continue
		_debris.push_back(debris)
		_xforms.push_back(debris.global_transform)
	print("Read " + str(_xforms.size()) + " debris pieces")
	pass

func _character_push_bodies(char:CharacterBody3D) -> void:
	for i in char.get_slide_collision_count():
		var collision:KinematicCollision3D = char.get_slide_collision(i)
		var body:RigidBody3D = collision.get_collider() as RigidBody3D
		if body == null:
			continue
		var pushDir:Vector3 = -collision.get_normal()
		var pushForce:float = 1.0
		body.freeze = false
		#body.apply_impulse(pushDir * pushForce, collision.get_position())
		body.apply_central_impulse(pushDir * pushForce)

func _character_tick(_delta:float) -> void:
	var move:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	#var v:Vector3 = Vector3(move.x, 0, move.y) * 5.0
	_character.velocity = Vector3(move.x, 0, move.y) * 5.0
	_character.move_and_slide()
	_character_push_bodies(_character)

func _restore_pieces() -> void:
	for i in range(0, _xforms.size()):
		var d:RigidBodyDebris = _debris[i]
		var t:Transform3D = _xforms[i]
		d.freeze = true
		d.global_transform = t

func _collapse() -> void:
	var o:Vector3 = _debrisChild.global_position
	for i in range(0, _debris.size()):
		var debris:RigidBodyDebris = _debris[i]
		debris.freeze = false
		_ray.from = o
		_ray.to = debris.global_position
		var hit:Dictionary = self.get_world_3d().direct_space_state.intersect_ray(_ray)
		if hit.is_empty():
			print("Push ray failed to hit debris!")
			continue
		var f:Vector3 = o.direction_to(debris.global_position)
		var n:Vector3 = hit.normal * 0.02
		var dir:Vector3 = (f + n).normalized()
		debris.apply_impulse(dir * 3.0, hit.position)
		
		#debris.linear_velocity = f * 2.0
		

func _burst() -> void:
	_restore_pieces()
	
	for i in range(0, _debris.size()):
		var debris:RigidBodyDebris = _debris[i]
		debris.freeze = false
		var f:Vector3 = self.global_position.direction_to(debris.global_position)
		debris.linear_velocity = f * 10.0

func _physics_process(_delta: float) -> void:
	_character_tick(_delta)
	match _state:
		STATE_NONE:
			if Input.is_action_just_pressed("attack_1"):
				_restore_pieces()
				_state = STATE_APPLY_COLLAPSE
		STATE_RUNNING:
			if Input.is_action_just_pressed("attack_1"):
				_restore_pieces()
				_state = STATE_NONE
		STATE_APPLY_COLLAPSE:
			_state = STATE_RUNNING
			_collapse()
	
