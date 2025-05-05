extends Node3D

@onready var _ring:Node3D = $ring

@export var time:float = 0.1
@export var remove_parent:bool = false
var _startTime:float = 0.1
var _ringTime:float = 0
var _ringMax:float = 0.2
var _ringMaxScale:float = 5.0

func _ready() -> void:
	_startTime = time
	pass

func _process(_delta:float):
	# shockwave ring scaling
	_ringTime += _delta
	var weight:float = _ringTime / _ringMax
	#weight = 1.0 - weight
	#weight = ZqfUtils.clamp_float(weight, 0.0, 1.0)
	if weight < 1.0:
		_ring.scale = Vector3(_ringMaxScale * weight, _ringMaxScale * weight, _ringMaxScale * weight)
	else:
		_ring.visible = false
	
	# life time
	time -= _delta
	if time <= 0:
		time = 99999999
		if remove_parent:
			get_parent().queue_free()
		else:
			self.queue_free()
