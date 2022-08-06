extends Spatial

onready var _ent:Entity = $Entity
onready var _marker:Spatial = $MeshInstance
onready var _audio:AudioStreamPlayer3D = $AudioStreamPlayer3D

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

func restore_state(_dict:Dictionary) -> void:
	global_transform = ZqfUtils.transform_from_dict(_dict.xform)
	_time = _dict.time
	_dir = _dict.dir
	active = _dict.active
	loop = _dict.loop

func on_trigger(_msg:String, _params:Dictionary) -> void:
	if _msg == "on":
		if _dir == 1:
			active = true
			_audio.play()
			_dir = -1
		# else:
		# 	active = true
		# 	_audio.play()
		# 	_dir = 1
		return
	if _msg == "off":
		if _dir == -1:
			active = true
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
	global_transform = _xformA.interpolate_with(_xformB, _time)
