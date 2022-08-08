extends Spatial

var _trackNodes = []
var _index:int = 0
var _weight:float = 0.0
var _stepMultiplier:float = 0.25
var _speed:float = 12.0
var _stepCount:int = 0

func _ready() -> void:
	_trackNodes = get_parent().find_node("track").get_children()
	print("Found " + str(_trackNodes.size()) + " track nodes")
	_stepMultiplier = _calc_current_step_multiplier()

func _get_next_track_index(index:int) -> int:
	var i:int = index + 1
	if i >= _trackNodes.size():
		return 0
	return i

func _get_transform_by_step(step:int) -> Transform:
	return _trackNodes[step % _trackNodes.size()].global_transform

func _calc_current_step_multiplier() -> float:
	var a:Transform = _trackNodes[_index].global_transform
	var b:Transform = _trackNodes[_get_next_track_index(_index)].global_transform
	var dist:float = a.origin.distance_to(b.origin)
	var step = 1 / (dist / _speed)
	return step

func _calc_step_multiplier(a:Transform, b:Transform) -> float:
	var dist:float = a.origin.distance_to(b.origin)
	var step = 1 / (dist / _speed)
	return step

func _calc_transform(weight:float) -> Transform:
	var a:Transform = _get_transform_by_step(_stepCount)
	var b:Transform = _get_transform_by_step(_stepCount + 1)
	var c:Transform = _get_transform_by_step(_stepCount + 2)
	var ab:Transform = a.interpolate_with(b, weight)
	var bc:Transform = b.interpolate_with(c, weight)
	var t:Transform = ab.interpolate_with(bc, 0.5)
	return t

func _calc_step_speed() -> void:
	var a:Transform = _get_transform_by_step(_stepCount)
	var b:Transform = _get_transform_by_step(_stepCount + 1)
	var c:Transform = _get_transform_by_step(_stepCount + 2)
	_stepMultiplier  = _calc_step_multiplier(a, c)
	# var stepMulAB:float = _calc_step_multiplier(a, b)
	# var stepMulBC:float = _calc_step_multiplier(b, c)
	# var s:float = lerp(stepMulAB, stepMulBC, _weight)
	# _stepMultiplier = s

func _process(_delta:float) -> void:
	_calc_step_speed()
	var step:float = _delta * _stepMultiplier
	_weight += step
	if _weight >= 1.0:
		_weight -= 1.0
		_stepCount += 1
	self.global_transform = _calc_transform(_weight)

