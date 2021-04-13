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
	var _r = _ent.connect("entity_append_state", self, "append_state")
	_r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_trigger", self, "on_trigger")

func append_state(_dict:Dictionary) -> void:
	_dict.xform = ZqfUtils.transform_to_dict(_root.global_transform)

func restore_state(_dict:Dictionary) -> void:
	_root.global_transform = ZqfUtils.transform_from_dict(_dict.xform)

func on_trigger() -> void:
	pass

func _process(delta) -> void:
	_time += delta * _dir
	if _time > 1:
		_time = 1
		_dir = -1
	elif _time < 0:
		_time = 0
		_dir = 1
	_root.global_transform = _a.global_transform.interpolate_with(_b.global_transform, _time)
