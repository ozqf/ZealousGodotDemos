extends Spatial

# root is the node that will be moved around
onready var _root:Spatial = $root
# a and b are the global positions root will be moved between
onready var _a:Spatial = $a
onready var _b:Spatial = $b
onready var _ent:Entity = $Entity

var _time:float = 0
var _dir:float = 1

func _ready():
	_a.visible = false
	_b.visible = false

func _process(delta) -> void:
	_time += delta * _dir
	if _time > 1:
		_time = 1
		_dir = -1
	elif _time < 0:
		_time = 0
		_dir = 1
	_root.global_transform = _a.global_transform.interpolate_with(_b.global_transform, _time)
