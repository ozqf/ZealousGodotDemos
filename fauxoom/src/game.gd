extends Spatial

const _GAME_SCENE_PATH = "res://maps/grid_map.tscn"
const _EDITOR_SCENE_PATH = "res://maps/level_editor.tscn"

const _TEST_MAP:String = "774BAAgIAQEBAQEBAQEBAQAAAAAAAAEBAAAAAAAAAQEAAAICAAABAQAAAgIAAAEBAAAAAAAAAQEAAAAAAAABAQEBAQEBAQHvvgIDAAYA"

enum AppState { Game, Editor }

var debugDegrees:float = 0
var debug_int:int = 0
var debugV3_1:Vector3 = Vector3()
var debugV3_2:Vector3 = Vector3()

onready var _menus:Control = $static_menus/menu
#onready var _title:Label = $CanvasLayer/title
onready var _debug_text:Label = $static_menus/debug/debug_text
onready var _debug_text_2:Label = $static_menus/debug/debug_text2
onready var _console:LineEdit = $static_menus/menu/console
onready var _mouseLock:MouseLock = $mouse_lock

var _state = AppState.Game
var _camera:Camera = null
var _emptyTrans:Transform = Transform.IDENTITY
var _url:String = ""
var _paramStr:String = ""

var _inputOn:bool = false

# current map being played or edited.
var _mapDef:MapDef = null
var _pendingMapDef:MapDef = null

func _parse_url_options(optionsStr:String) -> void:
	# eg ?foo=bar&a=b
	print("Parse URL options " + str(optionsStr))

func get_map() -> MapDef:
	if _mapDef == null:
		_mapDef = MapEncoder.b64_to_map(_TEST_MAP)
		# _mapDef = MapEncoder.empty_map(8, 8)
		# _mapDef.set_all(1)
	return _mapDef

func set_pending_map(newPendingMap:MapDef) -> void:
	if newPendingMap == null:
		return
	_pendingMapDef = newPendingMap

func on_game_play_level() -> void:
	_mapDef = _pendingMapDef
	var _state = AppState.Game
	get_tree().change_scene(_GAME_SCENE_PATH)

func on_game_edit_level() -> void:
	_mapDef = _pendingMapDef
	var _state = AppState.Editor
	get_tree().change_scene(_EDITOR_SCENE_PATH)

func set_input_on() -> void:
	_inputOn = true
	_menus.visible = false
	# MouseLock.remove_claim(get_tree(), "main_menu")
	_mouseLock.on_remove_mouse_claim("main_menu")

func set_input_off() -> void:
	_inputOn = false
	_menus.visible = true
	# MouseLock.add_claim(get_tree(), "main_menu")
	_mouseLock.on_add_mouse_claim("main_menu")

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
	add_to_group("game")

	set_input_off()
	
	AsciMapLoader.build_test_map()
	
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
		# _debug_text_2.text += "Exe path: " + OS.get_executable_path() + "\n"
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
			print("Toggle menu on")
			set_input_off()
			_console.grab_focus()
		else:
			print("Toggle menu off")
			set_input_on()
