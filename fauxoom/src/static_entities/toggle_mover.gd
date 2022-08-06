extends Spatial

onready var _ent:Entity = $Entity
onready var _marker:Spatial = $MeshInstance
onready var _audio:AudioStreamPlayer3D = $AudioStreamPlayer3D

export var startOn:bool = true
export var active:bool = false
export var loop:bool = false
export var seconds:float = 2
export(Vector3) var offset:Vector3 = Vector3()

var _time:float = 0
# dir 1 == moving from a to b
# dir -1 == moving from b to a
# a a == closed or 'on'
# at b == open or 'off'
var _dir:float = 1
var _xformA:Transform
var _xformB:Transform

func _ready():
	_marker.visible = false
	var _r = _ent.connect("entity_append_state", self, "append_state")
	_r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_trigger", self, "on_trigger")
	_ent.selfName = name
	_xformA = global_transform
	_xformB = global_transform
	_xformB.origin += offset

func append_state(_dict:Dictionary) -> void:
	_dict.xform = ZqfUtils.transform_to_dict(global_transform)
	_dict.time = _time
	_dict.dir = _dir
	_dict.active = active
	_dict.loop = loop
	_dict.startOn = startOn

func restore_state(_dict:Dictionary) -> void:
	ZqfUtils.safe_dict_apply_transform(_dict, "xform", self)
	_time = ZqfUtils.safe_dict_f(_dict, "time", _time)
	_dir = ZqfUtils.safe_dict_f(_dict, "dir", _dir)
	active = ZqfUtils.safe_dict_b(_dict, "active", active)
	loop = ZqfUtils.safe_dict_b(_dict, "loop", loop)
	startOn = ZqfUtils.safe_dict_b(_dict, "startOn", startOn)

func get_editor_info() -> Dictionary:
	var info:Dictionary = _ent.get_editor_info_just_tags()
	info.presets = ["on", "off"]
	#ZEEMain.create_field(info.fields, "time", "Time", "float", _time)
	return info

func apply_preset(presetName:String) -> void:
	if presetName == "off":
		_time = 1
		_dir = 1
	else:
		_time = 0
		_dir = -1
	_refresh_position()

func restore_from_editor(dict:Dictionary) -> void:
	_ent.restore_state(dict)

func _refresh_position() -> void:
	global_transform = _xformA.interpolate_with(_xformB, _time)

func on_trigger(_msg:String, _params:Dictionary) -> void:
	if _msg == "on":
		_dir = -1
		active = true
		_audio.play()
	if _msg == "off":
		_dir = 1
		active = true
		_audio.play()
	if !active:
		active = true
		_audio.play()
	# print("Toggle mover active")

func _process(delta) -> void:
	if !active:
		return
	var mul:float = seconds
	if mul <= 0:
		mul = 0.1
	_time += (delta / mul) * _dir
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
	_refresh_position()
