extends CharacterBody3D
class_name DecalThrownBloodSplat

@onready var _decal:Decal = $Decal
@onready var _shape:CollisionShape3D = $CollisionShape3D

var _gravity:Vector3 = Vector3(0, -20, 0)
var _dirty:bool = true
var _shapeDisabled:bool = false

func _ready():
	_decal.visible = false
	self.set_physics_process(false)
	_shapeDisabled = true
	_dirty = true

func throw_decal(origin:Vector3, forward:Vector3, speed:float = 10) -> void:
	self.global_position = origin
	self.look_at(origin + forward, Vector3.UP)
	self.velocity = forward * speed
	self.set_physics_process(true)
	_shapeDisabled = false
	_dirty = true

func _process(_delta:float) -> void:
	if _dirty:
		_dirty = false
		_shape.disabled = _shapeDisabled

func _physics_process(_delta:float) -> void:
	self.velocity += (_gravity * _delta)
	var move:Vector3 = self.velocity * _delta
	var collision:KinematicCollision3D = self.move_and_collide(move)
	if collision == null || collision.get_collision_count() == 0:
		return
	#var obj:CollisionObject3D = (collision.get_collider(0) as CollisionObject3D)
	#if obj != null:
	#	print(str(obj.collision_layer))
	self.global_position = collision.get_position()
	_decal.visible = true
	self.set_physics_process(false)
	_shapeDisabled = true
	_dirty = true
