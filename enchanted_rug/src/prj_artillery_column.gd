extends Spatial

const STATE_IDLE:int = 0
const STATE_FLYING:int = 1
const STATE_DETONATING:int = 2
const STATE_DEAD:int = 3

var _state:int = STATE_IDLE
var _tick:float = 0.0

var _flightTime:float = 1.0
var _detonateTime:float = 2.0

var _launchOrigin:Vector3 = Vector3()
var _dest:Vector3 = Vector3()
var _destForward:Vector3 = Vector3()

func _process(_delta:float) -> void:

	if _state == STATE_FLYING:
		_tick += _delta
		if _tick >= _flightTime:
			_detonate()
			return
		var pos:Vector3 = _launchOrigin.linear_interpolate(_dest, _tick / _flightTime)
		global_transform.origin = pos
	if _state == STATE_DETONATING:
		_tick += _delta
		if _tick > _detonateTime:
			queue_free()
			_state = STATE_DEAD
		return

func _detonate() -> void:
	_state = STATE_DETONATING
	_tick = 0.0
	get_node("column_mesh").visible = true
	get_node("shell_mesh").visible = false
	global_transform.origin = _dest
	ZqfUtils.look_at_safe(self, _dest + Vector3.UP)
	# ZqfUtils.look_at_safe(self, _dest + _destForward)

func prj_launch(_pos:Vector3, _dir:Vector3, _spinStartDegrees:float = 0, _spinRateDegrees:float = 0) -> void:
	var hit:Dictionary = ZqfUtils.hitscan_by_direction_3D(self, _pos, _dir, 1000, ZqfUtils.EMPTY_ARRAY, 1)
	var spawnPoint:Vector3 = _pos + (_dir * 1000)
	var forward:Vector3 = Vector3.UP
	if hit:
		spawnPoint = hit.position
		forward = hit.normal
	_launchOrigin = _pos
	_dest = spawnPoint
	_destForward = forward
	global_transform.origin = _pos
	_state = STATE_FLYING
	get_node("column_mesh").visible = false
	get_node("shell_mesh").visible = true
	
	ZqfUtils.look_at_safe(self, spawnPoint)
	pass
