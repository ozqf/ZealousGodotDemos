extends Node

@onready var _root:Node3D = $conveyor
var _start:Vector3
var _end:Vector3
var _weights:PackedFloat32Array = PackedFloat32Array()
var _tick:float = 0.0

func _ready() -> void:
	var numChildren:int = _root.get_child_count()
	_start = _root.get_child(0).position
	_end = _root.get_child(numChildren - 1).position
	var totalDist:float = _start.distance_to(_end)
	for child in _root.get_children():
		var pos:Vector3 = child.position
		var dist:float = pos.distance_to(_start)
		_weights.push_back(dist / totalDist)

func _process(_delta:float) -> void:
	_tick += _delta
	var numChildren:int = _root.get_child_count()
	for i in range(0, numChildren):
		var weight:float = _weights[i]
		var time:float = _tick + weight
		time = time - int(time)
		var c:Node3D = _root.get_child(i) as Node3D
		c.position = _start.lerp(_end, time)
