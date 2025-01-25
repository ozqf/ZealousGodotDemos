extends Area3D
class_name HurtboxArea3D

signal on_check_for_victims(_hurtbox:HurtboxArea3D, _areas:Array[Area3D])
signal on_hit_victim(_hurtbox:HurtboxArea3D, victim:Area3D)

@onready var _indicator:AttackIndicator = $AttackIndicatorSphere

enum State {
	Inactive,
	WindUp,
	Active
}

var _state:State = State.Inactive
var _tick:float = 0.0
var _windUpTime:float = 0.0
var _activeDuration:float = 0.0

var showAttackIndicators:bool = true

func _ready() -> void:
	self.connect("area_entered", _on_area_entered)
	clear()

func _on_area_entered(_area:Area3D) -> void:
	on_hit_victim.emit(self, _area)

func check_start_from_move(move:Dictionary, startKey:String, endKey:String, speedModifier:float = 1.0) -> void:
	var start = ZqfUtils.safe_dict_f(move, startKey, 0.0) / speedModifier
	var end = ZqfUtils.safe_dict_f(move, endKey, 0.1) / speedModifier
	if start <= 0:
		return
	if end <= start:
		end = start + 0.1
	run(start, end - start)

func run(windUpTime:float = 0.1, duration:float = 0.1) -> void:
	#if windUpTime <= 0.0:
	#	clear()
	#	return
	_windUpTime = windUpTime
	_tick = windUpTime
	_activeDuration = duration
	_state = State.WindUp
	set_process(true)
	if showAttackIndicators:
		_indicator.visible = true

func clear() -> void:
	_indicator.visible = false
	monitoring = false
	set_process(false)

func _process(_delta:float) -> void:
	match _state:
		State.WindUp:
			_tick -= _delta
			if showAttackIndicators:
				var weight:float = (_tick / _windUpTime)
				_indicator.refresh(weight)
			if _tick <= 0.0:
				_state = State.Active
				_tick = _activeDuration
				monitoring = true
		State.Active:
			_tick -= _delta
			if _tick <= 0.0:
				clear()
		_:
			clear()
			pass
