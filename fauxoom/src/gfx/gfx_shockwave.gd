extends Node3D

var _running:bool = true
var _scaleTarget:float = 1.0
var _currentScale:float = 1.0
var _scaleRate:float = 40.0

func _process(_delta:float) -> void:
	if !_running:
		return
	_currentScale += _scaleRate * _delta
	if _currentScale > _scaleTarget:
		queue_free()
		_running = false
	scale = Vector3(_currentScale, 1.0, _currentScale)

func run(scaleTarget:float) -> void:
	_scaleTarget = scaleTarget
