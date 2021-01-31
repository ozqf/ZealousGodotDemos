extends Spatial

var debugDegrees:float = 0
var debug_int:int = 0
var debugV3_1:Vector3 = Vector3()
var debugV3_2:Vector3 = Vector3()

onready var _menus:Control = $CanvasLayer/menu
#onready var _title:Label = $CanvasLayer/title
onready var _debug_text:Label = $CanvasLayer/debug_text
onready var _debug_text_2:Label = $CanvasLayer/debug_text2
onready var _console:LineEdit = $CanvasLayer/menu/console

var _camera:Camera = null
var _emptyTrans:Transform = Transform.IDENTITY
var _url:String = ""
var _paramStr:String = ""

var _inputOn:bool = false

func _parse_url_options(optionsStr:String) -> void:
	# eg ?foo=bar&a=b
	print("Parse URL options " + str(optionsStr))
	pass

func set_input_on() -> void:
	_inputOn = true
	_menus.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func set_input_off() -> void:
	_inputOn = false
	_menus.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _web_mode() -> bool:
	return (OS.get_name() == "HTML5")

func get_input_on() -> bool:
	return _inputOn

func _refresh_input_on():
	if Input.is_action_just_pressed("ui_cancel"):
		if _inputOn:
			set_input_off()
		else:
			set_input_on()

func _ready():
	print("Game service start")
	
	if OS.has_feature("JavaScript"):
		print("JS available")
		# get full url
		var js_result = JavaScript.eval("""
			var js_result;
			js_result = window.location.href;
		""")
		if js_result is String:
			_url = js_result
		else:
			print("ERROR: JS url result was not a string!")
		# get params
		js_result = JavaScript.eval("""
			var js_result;
			js_result = window.location.search
		""")
		# print("URL location: " + str(js_result))
		_parse_url_options(js_result)
	else:
		print("JS not available")
	
	_debug_text_2.text = ""
	if _web_mode():
		_debug_text_2.text += "URL: " + _url + "\n"
	else:
		_debug_text_2.text += "CmdLine: " + str(OS.get_cmdline_args().join(", ")) + "\n"
		_debug_text_2.text += "Exe path: " + OS.get_executable_path() + "\n"
		_debug_text_2.text += "Platform: " + OS.get_name() + "\n"
	_debug_text_2.text += "ESCAPE or TAB to toggle mouse capture\n"
	_debug_text_2.text += "WASD - move | Mouse - aim/shoot\n"
	_debug_text_2.text += "1,2,3,4,5 - Weapon select\n"
#	_debug_text_2.text += "Build time: 2021/1/3 19:22\n"

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

	_debug_text.text = "FPS: " + str(Engine.get_frames_per_second()) + "\n"
	var time = OS.get_time()
	_debug_text.text += str(time.hour) + ":" + str(time.minute) + ":" + str(time.second) + "\n"
	var ratio:Vector2 = ZqfUtils.get_window_to_screen_ratio()
	_debug_text.text += "Window/Scr ratio: " + str(ratio)
#	_debug_text.text = "Vec 1: " + str(debugV3_1) + "\n"
#	_debug_text.text += "Vec 2: " + str(debugV3_2) + "\n"
#	_debug_text.text += "Degrees: " + str(debugDegrees) + "\n"
#	_debug_text.text += "Index " + str(debug_int) + "\n"

func _input(_event: InputEvent):
	var menuCode = KEY_ESCAPE
	if _web_mode():
		menuCode = KEY_TAB
	if _event is InputEventKey && _event.scancode == menuCode && _event.pressed && !_event.echo:
		if _inputOn:
			_inputOn = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			_menus.visible = true
			_console.grab_focus()
		else:
			_inputOn = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			_menus.visible = false
	#if _event is InputEventKey:
	#	_refresh_input_on()
