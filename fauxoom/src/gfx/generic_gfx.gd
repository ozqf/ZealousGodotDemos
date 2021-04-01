extends AnimatedSprite3D

export var frameIndices = [ 100, 101, 102 ]
var _currentFrame:int = 0
var _frameTime:float = 1.0 / 10.0
var _tick:float = 0.0
var _active:bool = true

func _ready():
	frame = frameIndices[_currentFrame]
	_tick = _frameTime
	var _min:float = 1.0 / 10.0
	var _max:float = 1.0 / 15.0
	_frameTime = rand_range(_min, _max)

func _process(delta):
	if !_active:
		return
	_tick -= delta
	if _tick <= 0:
		_currentFrame += 1
		if _currentFrame >= frameIndices.size():
			_active = false
			queue_free()
			return
		_tick = _frameTime
		frame = frameIndices[_currentFrame]
