extends Node3D
class_name MeleeAttackIndicator

var _isRunning:bool = false
var _tick:float = 0.0
var _time:float = 1.0

var _startScale:Vector3 = Vector3(1, 1, 1)
var _endScale:Vector3 = Vector3(0, 0, 0)

func _ready():
	off()

func off() -> void:
	_isRunning = false
	self.visible = false
	set_process(false)

func refresh() -> void:
	var newScale:Vector3 = _startScale.lerp(_endScale, _tick / _time)
	#print("New scale " + str(newScale))
	self.scale = newScale

func remaining_time() -> float:
	return clampf(_time - _tick, 0.0, _time)

func run(duration:float) -> void:
	if _isRunning:
		return
	_isRunning = true
	_time = duration
	_tick = 0.0
	self.visible = true
	set_process(true)
	refresh()

func _process(delta:float) -> void:
	_tick += delta
	if _tick >= _time:
		off()
		return
	refresh()
