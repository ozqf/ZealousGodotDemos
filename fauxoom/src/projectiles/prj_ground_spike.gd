extends Spatial

onready var _cone:MeshInstance = $cone

var _spikeState:int = 0

var _time:float = 0

func _set_scale(weight:float) -> void:
	if weight > 1:
		weight = 1
	if weight < 0:
		weight = 0
	var t:float = lerp(0, 1, weight)
	_cone.scale = Vector3(t, t, t)
	_cone.transform.origin = Vector3(0, t, 0)
	visible = true

func _process(_delta:float) -> void:
	_time += _delta
	var weight:float = 1
	if _spikeState == 0:
		weight = _time / 0.2
		if _time > 0.2:
			_time = 0
			_spikeState = 1
	elif _spikeState == 1:
		if _time > 2:
			_time = 0
			_spikeState = 2
	elif _spikeState == 2:
		weight = _time / 1
		weight = 1 - weight
		if _time > 1:
			_time = 0
			# _spikeState = 0
			queue_free()
	else:
		return
	_set_scale(weight)
