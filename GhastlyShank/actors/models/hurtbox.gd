extends Area3D
class_name HurtboxArea3D

signal on_check_for_victims(_hurtbox:HurtboxArea3D, _areas:Array[Area3D])

@onready var _indicator:AttackIndicator = $AttackIndicatorSphere

var _tick:float = 0.0
var _time:float = 0.0

var showAttackIndicators:bool = true

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
	if showAttackIndicators:
		_indicator.visible = true

func clear() -> void:
	_indicator.visible = false
	monitoring = false
	set_process(false)

func _process(_delta:float) -> void:
	_tick -= _delta
	if showAttackIndicators:
		var weight:float = (_tick / _time)
		_indicator.refresh(weight)
	#print(str(_tick))
	if _tick <= 0.0:
		_tick = 999
		# check for hits
		#print(get_parent().name + " check for hits")
		on_check_for_victims.emit(self, self.get_overlapping_areas())
		clear()
