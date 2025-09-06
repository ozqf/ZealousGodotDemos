extends Node3D

var _bulletType:PackedScene = preload("res://test_09_bullets/bullet.tscn")

var _phaseTick:int = 0
var _patternTick:int = 0
var _patternTock:int = 0
var _patternRepeats:int = 5

static func calc_fan_yaw(spreadDegrees:float, prjIndex:int, prjTotal:int) -> float:
	if spreadDegrees == 0.0 || prjTotal < 2:
		return 0.0
	#-(arc * 0.5) + ((arc / (total - 1) * i))
	var result:float = -(spreadDegrees * 0.5) + ((spreadDegrees / (prjTotal - 1)) * prjIndex)
	return result

static func yaw_to_flat_vector3(yawDegrees:float) -> Vector3:
	var radians:float = deg_to_rad(yawDegrees)
	#return Vector3(sin(radians), 0, -cos(radians))
	return Vector3(cos(radians), 0, -sin(radians))
	#return Vector3(-sin(radians), 0, -cos(radians))

func _fire_bullet(origin:Vector3, yawDegrees:float, speed:float) -> void:
	var dir:Vector3 = yaw_to_flat_vector3(yawDegrees)
	var vel:Vector3 = dir * speed
	var bullet = _bulletType.instantiate()
	add_child(bullet)
	bullet.global_position = origin
	bullet.velocity = vel

func _check_fire_pattern1(tick:int) -> bool:
	if tick % 4 != 0:
		return false
	if tick > 30 and tick < 60:
		return true
	if tick > 90 and tick < 120:
		return true
	return false

func _tick_phase_1(_delta:float) -> bool:
	var lastFrame:int = 150
	var baseYaw:float = 0.0
	var phaseWeight:float = float(_patternTick) / lastFrame
	
	if _check_fire_pattern1(_patternTick):
		var yaw:float = baseYaw + 270
		_fire_bullet(self.global_position, yaw - 30, 4)
		_fire_bullet(self.global_position, yaw, 4)
		_fire_bullet(self.global_position, yaw + 30, 4)
	
	if _patternTick > 30 and _patternTick < 120 && (_patternTick % 20) == 0:
		var numBullets:int = 12
		for i in range(0, numBullets):
			var offset:float = calc_fan_yaw(60, i, numBullets)
			var yaw:float = baseYaw + 270 + offset
			_fire_bullet(self.global_position, yaw, 8)
	
	_patternTick += 1
	_phaseTick += 1
	if _phaseTick > lastFrame:
		_phaseTick = 0
		_patternTick = 0
		_patternTock += 1
	return _patternTock < _patternRepeats

func _physics_process(_delta: float) -> void:
	_tick_phase_1(_delta)
