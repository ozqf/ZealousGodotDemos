extends Area3D
class_name HurtboxArea3D

signal on_check_for_victims(_hurtbox:HurtboxArea3D, _areas:Array[Area3D])

var _tick:float = 0.0
var _time:float = 0.0

func _ready() -> void:
	clear()

func run(timeToRun:float = 0.1) -> void:
	if timeToRun <= 0.0:
		clear()
		return
	_time = timeToRun
	_tick = _time
	monitoring = true
	set_process(true)

func clear() -> void:
	monitoring = false
	set_process(false)

func _process(_delta:float) -> void:
	_tick -= _delta
	#print(str(_tick))
	if _tick <= 0.0:
		_tick = 999
		# check for hits
		#print(get_parent().name + " check for hits")
		on_check_for_victims.emit(self, self.get_overlapping_areas())
		clear()
