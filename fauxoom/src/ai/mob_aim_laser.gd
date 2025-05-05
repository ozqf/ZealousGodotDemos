extends RayCast3D

@onready var _a:MeshInstance3D = $rotator/Spatial/MeshInstance3D
@onready var _b:MeshInstance3D = $rotator/Spatial/MeshInstance2
@onready var _c:MeshInstance3D = $rotator/Spatial/MeshInstance3
@onready var _d:MeshInstance3D = $rotator/Spatial/MeshInstance4
@onready var _rotator:Node3D = $rotator

# @onready var _defaultLength:float = 50
@onready var _ignoreRaycast:bool = false

var _on:bool = false
var _tick:float = 0
var _duration:float = 1
var _maxRadius:float = 0.8
var _maxRotationDegrees:float = 180
var _autoOff:bool = true

func _ready():
	visible = false

func on(duration:float, autoOff:bool) -> void:
	_tick = 0
	_on = true
	_duration = duration
	visible = true
	_autoOff = autoOff
	_update_offsets(0)

func _update_offsets(_lerp:float) -> void:
	var degrees:float = lerp(0, _maxRotationDegrees, _lerp)
	_rotator.rotation_degrees.z = degrees

	var offset:Vector3 = Vector3()
	offset.x = 0
	offset.y = lerp(_maxRadius, 0, _lerp)
	offset.z = 0
	_a.transform.origin = offset

	offset.y = lerp(-_maxRadius, 0, _lerp)
	_b.transform.origin = offset

	offset.x = lerp(_maxRadius, 0, _lerp)
	offset.y = 0
	_c.transform.origin = offset

	offset.x = lerp(-_maxRadius, 0, _lerp)
	_d.transform.origin = offset

func off() -> void:
	visible = false
	_on = false

func _process(delta) -> void:
	if !_on:
		return
	_tick += delta
	if _tick > _duration:
		if _autoOff:
			off()
		return
	if _ignoreRaycast || is_colliding():
		var origin:Vector3 = global_transform.origin
		var dest:Vector3 = get_collision_point()
		var dist:float = origin.distance_to(dest)
		_rotator.scale = Vector3(1, 1, dist)
		_rotator.transform.origin.z = -dist / 2.0
		# print("mob laser hit dist: " + str(dist))
	var lerpValue:float = _tick / _duration
	_update_offsets(lerpValue)
