extends Spatial

# root is the node that will be moved around
onready var _root:Spatial = $root
# a and b are the global positions root will be moved between
onready var _a:MeshInstance = $a
onready var _b:MeshInstance = $b
onready var _ent:Entity = $Entity

export var active:bool = false
export var loop:bool = false

var _time:float = 0
var _dir:float = 1

func _ready():
	_root.mesh = null
	_a.visible = false
	_b.visible = false
	var _r = _ent.connect("entity_append_state", self, "append_state")
	_r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_trigger", self, "on_trigger")
	_ent.selfName = name

func append_state(_dict:Dictionary) -> void:
	_dict.xform = ZqfUtils.transform_to_dict(_root.global_transform)
	_dict.time = _time
	_dict.dir = _dir
	_dict.active = active
	_dict.loop = loop

func restore_state(_dict:Dictionary) -> void:
	_root.global_transform = ZqfUtils.transform_from_dict(_dict.xform)
	_time = _dict.time
	_dict.dir = _dir
	_dict.active = active
	_dict.loop = loop

func on_trigger(_msg:String, _params:Dictionary) -> void:
	if !active:
		active = true

func _process(delta) -> void:
	if !active:
		return
	_time += delta * _dir
	if _time > 1:
		_time = 1
		_dir = -1
		if !loop:
			active = false
	elif _time < 0:
		_time = 0
		_dir = 1
		if !loop:
			active = false
	_root.global_transform = _a.global_transform.interpolate_with(_b.global_transform, _time)
