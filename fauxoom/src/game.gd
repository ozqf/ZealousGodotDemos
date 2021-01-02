extends Spatial

var debugDegrees:float = 0
var debug_int:int = 0
var debugV3_1:Vector3 = Vector3()
var debugV3_2:Vector3 = Vector3()

onready var _debug_text:Label = $CanvasLayer/debug_text
var _camera:Camera = null
var _emptyTrans:Transform = Transform.IDENTITY

func _ready():
	print("Game service start")

func set_camera(cam:Camera) -> void:
	if cam == null:
		return
	_camera = cam

func clear_camera(cam:Camera) -> void:
	if cam != null && _camera == cam:
		_camera = null

func get_camera_pos() -> Transform:
	if _camera != null:
		return _camera.global_transform
	return _emptyTrans

func _process(_delta) -> void:
	_debug_text.text = "FPS: " + str(Engine.get_frames_per_second())
#	_debug_text.text = "Vec 1: " + str(debugV3_1) + "\n"
#	_debug_text.text += "Vec 2: " + str(debugV3_2) + "\n"
#	_debug_text.text += "Degrees: " + str(debugDegrees) + "\n"
#	_debug_text.text += "Index " + str(debug_int) + "\n"
