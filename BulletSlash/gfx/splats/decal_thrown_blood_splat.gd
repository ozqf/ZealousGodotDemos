extends CharacterBody3D
class_name DecalThrownBloodSplat

@onready var _decal:Decal = $Decal
@onready var _shape:CollisionShape3D = $CollisionShape3D
@onready var _neighbourDetector:Area3D = $neighbour_detector

var ticksAlive:int = 0

var _checkNeighboursTick:int = 0

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

func _check_neighbours() -> void:
	var others:Array[Area3D] = _neighbourDetector.get_overlapping_areas()
	var num:int = others.size()
	if num < 6:
		return
	for i in range(0, num):
		# TODO: Jank - assuming parent type
		var other:DecalThrownBloodSplat = others[i].get_parent() as DecalThrownBloodSplat
		if other.ticksAlive > self.ticksAlive:
			return
	# no one is older than us - adios
	#print("Splat culled at age " + str(self.ticksAlive))
	self.queue_free()

func _process(_delta:float) -> void:
	if _dirty:
		_dirty = false
		_shape.disabled = _shapeDisabled
	ticksAlive += 1
	_checkNeighboursTick += 1
	if _checkNeighboursTick > 60:
		_checkNeighboursTick = 0
		_check_neighbours()

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
