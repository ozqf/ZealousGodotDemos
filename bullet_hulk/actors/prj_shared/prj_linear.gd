extends Node3D
class_name PrjLinear

@onready var _launch:PrjLaunchInfo = $PrjLaunchInfo
@onready var _shape:CollisionShape3D = $CollisionShape3D

var _tick:float = 0.0
var _queryTick:int = 0
var _shapeQuery:PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
var _atk:AttackInfo = AttackInfo.new()

func _physics_process(delta: float) -> void:
	_tick += delta
	if _tick >= 10.0:
		self.queue_free()
	var t:Transform3D = self.global_transform
	var f:Vector3 = -t.basis.z
	var p:Vector3 = t.origin
	p += (f * _launch.speed) * delta
	self.global_position = p
	_queryTick += 1
	if _queryTick % 3 == 0:
		_check_for_hits()

func _check_for_hits() -> void:
	# touch player
	var space:PhysicsDirectSpaceState3D = self.get_world_3d().direct_space_state
	_shapeQuery.shape = _shape.shape
	_shapeQuery.collide_with_areas = true
	_shapeQuery.collide_with_bodies = false
	_shapeQuery.collision_mask = Interactions.LAYER_PLAYER_AVATAR
	_shapeQuery.transform = _shape.global_transform

	var hits:Array[Dictionary] = space.intersect_shape(_shapeQuery, 1)
	if hits.size() == 0:
		return
	var result:int = Interactions.try_hurt(_atk, hits[0].collider)
	if result >= 0 || result == Interactions.HIT_SOLID:
		self.queue_free()


func get_launch_info() -> PrjLaunchInfo:
	return _launch

func launch_projectile() -> void:
	self.global_position = _launch.origin
	self.look_at(_launch.origin + _launch.forward)
	if _launch.rollDegrees != 0.0:
		var t:Transform3D = self.global_transform
		self.rotate(t.basis.z, deg_to_rad(_launch.rollDegrees))
