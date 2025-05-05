extends Node3D
class_name TeleportColumn

const spinRate:float = 720.0

@onready var a:MeshInstance3D = $MeshInstance3D
@onready var b:MeshInstance3D = $MeshInstance2
@onready var c:MeshInstance3D = $MeshInstance3
@onready var d:MeshInstance3D = $MeshInstance4

var _duration:float = 2
var _tick:float = 0
var _degrees:float = 0
var _spinDegreesPerSecond:float = 720

func _ready() -> void:
	visible = false
#	run(2)

func run(duration:float) -> void:
	visible = true
	_duration = duration
	_tick = 0
	if randf() > 0.5:
		_spinDegreesPerSecond = randf_range(spinRate / 2, spinRate)
	else:
		_spinDegreesPerSecond = randf_range(-spinRate / 2, -spinRate)

func append_state(dict:Dictionary) -> void:
	dict.tpc_vis = visible
	dict.tpc_tick = _tick
	dict.tpc_deg = _degrees
	dict.tpc_degps = _spinDegreesPerSecond

func restore_state(dict:Dictionary) -> void:
	visible = ZqfUtils.safe_dict_b(dict, "tpc_vis", visible)
	_tick = ZqfUtils.safe_dict_f(dict, "tpc_tick", _tick)
	_degrees = ZqfUtils.safe_dict_f(dict, "tpc_deg", _degrees)
	_spinDegreesPerSecond = ZqfUtils.safe_dict_f(dict, "tpc_degps", _spinDegreesPerSecond)
	_refresh()

func _refresh() -> void:
	var time:float = _tick / _duration
	var newScale:Vector3 = Vector3(lerp(1, 0, time), 1, 1)
	a.scale = newScale
	b.scale = newScale
	c.scale = newScale
	d.scale = newScale
	self.rotation_degrees.y = _degrees

func tick(_delta:float) -> bool:
	_tick += _delta
	_degrees += _spinDegreesPerSecond * _delta
	if _tick >= _duration:
		_tick = 0
		visible = false
		return true
	_refresh()
	return false
#	a.rotation_degrees.y = _degrees
#	b.rotation_degrees.y = _degrees + 90.0
#	c.rotation_degrees.y = _degrees + 180.0
#	d.rotation_degrees.y = _degrees + 270.0
#	var halfDuration:float = _duration / 2
#	var firstPhase:bool = _tick < halfDuration
#	if firstPhase:
#		var time:float = _tick / halfDuration
#		pass
#	else:
#		pass
