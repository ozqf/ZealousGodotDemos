extends Spatial

onready var _floor:RayCast = $floor
onready var _ceiling:RayCast = $ceiling

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

func launch(pos:Vector3, dir:Vector3, _spinStartDegrees:float = 0, _spinRateDegrees:float = 0) -> void:
	var t:Transform = global_transform
	t.origin = pos
	global_transform = t

	look_at(pos + dir, Vector3.UP)
	# var flatDir:Vector3 = Vector3(dir.x, 0, dir.z)
	# flatDir = flatDir.normalized()
	# look_at(pos + flatDir, Vector3.UP)
	
	var rot:Vector3 = rotation_degrees
	rot.z = _spinStartDegrees
	rotation_degrees = rot
	spinRateDegrees = _spinRateDegrees

