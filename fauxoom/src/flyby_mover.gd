extends Spatial

var _trackNodes = []
var _index:int = 0
var _weight:float = 0.0
var _stepMultiplier:float = 0.25
var _speed:float = 4.0

func _ready() -> void:
	_trackNodes = get_parent().find_node("track").get_children()
	print("Found " + str(_trackNodes.size()) + " track nodes")
	_stepMultiplier = _calc_current_step_multiplier()

func _get_next_track_index(index:int) -> int:
	var i:int = index + 1
	if i >= _trackNodes.size():
		return 0
	return i

func _calc_current_step_multiplier() -> float:
	var a:Transform = _trackNodes[_index].global_transform
	var b:Transform = _trackNodes[_get_next_track_index(_index)].global_transform
	var dist:float = a.origin.distance_to(b.origin)
	var step = 1 / (dist / _speed)
	return step

func _process(_delta:float) -> void:
	var step:float = _delta * _stepMultiplier
	_weight += step
	var t:Transform
	var a:Transform = _trackNodes[_index].global_transform
	var b:Transform = _trackNodes[_get_next_track_index(_index)].global_transform
	if _weight < 1:
		t = a.interpolate_with(b, _weight)
	else:
		t = b
		_weight = 0
		_index = _get_next_track_index(_index)
		# measure speed for next move
		_stepMultiplier = _calc_current_step_multiplier()
	self.global_transform = t
