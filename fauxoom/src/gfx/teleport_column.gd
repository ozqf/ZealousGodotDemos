extends Spatial
class_name TeleportColumn

onready var a:MeshInstance = $MeshInstance
onready var b:MeshInstance = $MeshInstance2
onready var c:MeshInstance = $MeshInstance3
onready var d:MeshInstance = $MeshInstance4

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

#func _process(_delta:float) -> void:
#	tick(_delta)

func tick(_delta:float) -> bool:
	_tick += _delta
	_degrees += _spinDegreesPerSecond * _delta
	if _tick >= _duration:
		_tick = 0
		visible = false
		return true
	var time:float = _tick / _duration
	var newScale:Vector3 = Vector3(lerp(1, 0, time), 1, 1)
	a.scale = newScale
	b.scale = newScale
	c.scale = newScale
	d.scale = newScale
	self.rotation_degrees.y = _degrees
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
