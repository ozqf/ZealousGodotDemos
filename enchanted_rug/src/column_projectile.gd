extends Spatial

onready var _floor:RayCast = $floor
onready var _ceiling:RayCast = $ceiling
onready var _moveStats:ProjectileMovement = $ProjectileMovement

export var speed:float = 1
export var minSpeed:float = 1
export var maxSpeed:float = 100
export var acceleration:float = 25
export var spinRateDegrees:float = 22.5

var _ttl:float = 10
var _dead:bool = false

var _growthRate:float = 25
var _currentFloorScale:float = 1
var _currentCeilingScale:float = 1

func remove() -> void:
	if _dead:
		return
	_dead = true
	queue_free()

func _physics_process(delta) -> void:
	_ttl -= delta
	if _ttl <= 0:
		remove()
		return
	
	# adjust speed
	speed += acceleration * delta
	if speed > maxSpeed:
		speed = maxSpeed
	if speed < minSpeed:
		speed = minSpeed
	
	var move:Vector3 = (-global_transform.basis.z * speed) * delta
	var t:Transform = global_transform
	t.origin += move
	global_transform = t
	var degrees = rotation_degrees
	degrees.z += spinRateDegrees * delta
	rotation_degrees = degrees
	# var hit = move_and_collide(move)
	# if hit != null:
	# 	remove()
	# 	return
	
	# adjust size
	var origin:Vector3 = global_transform.origin
	var floorScale:float = 100
	var ceilingScale:float = 100

	if _floor.is_colliding():
		floorScale = origin.distance_to(_floor.get_collision_point())
		# var floorPos:Vector3 = _floor.get_collision_point()
		# floorScale = abs(origin.y - floorPos.y)
	
	if _currentFloorScale < floorScale:
		_currentFloorScale += _growthRate * delta
	if _currentFloorScale > floorScale:
		_currentFloorScale = floorScale
	
	$down.scale = Vector3(1, _currentFloorScale, 1)
	
	if _ceiling.is_colliding():
		ceilingScale = origin.distance_to(_ceiling.get_collision_point())
		# var ceilingPos:Vector3 = _ceiling.get_collision_point()
		# ceilingScale = abs(ceilingPos.y + origin.y)
	
	if _currentCeilingScale < ceilingScale:
		_currentCeilingScale += _growthRate * delta
	if _currentCeilingScale > ceilingScale:
		_currentCeilingScale = ceilingScale
	$up.scale = Vector3(1, _currentCeilingScale, 1)

func copy_settings(move:ProjectileMovement) -> void:
	move.apply_to(self)

func prj_launch(_launchInfo:PrjLaunchInfo) -> void:
	var t:Transform = global_transform
	t.origin = _launchInfo.origin
	global_transform = t

	ZqfUtils.look_at_safe(self, t.origin + _launchInfo.forward)
	
	var rot:Vector3 = rotation_degrees
	rot.z = _launchInfo.spinStartDegrees
	rotation_degrees = rot
	spinRateDegrees = _launchInfo.spinRateDegrees

