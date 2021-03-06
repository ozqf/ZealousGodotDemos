extends Spatial

const _GAME_SCENE_PATH = "res://maps/grid_map.tscn"
const _EDITOR_SCENE_PATH = "res://maps/level_editor.tscn"

# const _DEFAULT_CFG_NAME = "fauxoom"

# smaller test
const _TEST_MAP:String = "774BAAgIAQEBAQEBAQEBAQAAAAAAAAEBAAAAAAAAAQEAAAICAAABAQAAAgIAAAEBAAAAAAAAAQEAAAAAAAABAQEBAQEBAQHvvgIDAAYA"

# 24x24 test
# const _TEST_MAP_2:String = "774BABgYBAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAAAAAAABAQEBAQEBAQEBAQEBAQEAAAAAAAAAAAABAQEBAQEBAQEBAQEBAQEAAAICAgICAgICAgIBAQEBAQEBAQEBAQEAAAICAgICAgICAgIBAQEBAQEBAQEBAQEAAAAAAAAAAAABAQEBAQEBAQEBAQEBAQEAAAAAAAAAAAABAQEBAQEBAQEBAQEBAQEBAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAe++AgIAFgABBQASAAEJAA4AAQkAEQA="
const _TEST_MAP_2:String = "774BABgYAgEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAQEBAAAAAAAAAAABAQEAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEAAAEBAQEBAQEAAAAAAAAAAAABAQEAAAAAAAAAAAEBAQEAAAAAAAAAAAABAQAAAAAAAAAAAAABAQEAAAICAgICAgICAgICAgIAAAICAgICAQEAAAICAgICAgICAgICAgIAAAICAgICAQEAAAAAAAAAAAABAQEAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAQEBAAEBAQEBAAAAAAEAAAAAAQEAAAAAAQEAAAABAQEBAAAAAAAAAAAAAQEAAAAAAQEAAAABAQEBAAAAAAAAAAAAAAAAAAAAAQEAAAABAQEBAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAe++AgsACQABDwAEQw=="
const _TEST_MAP_3:String = "774BABgYBAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAQEBAAAAAAAAAAABAQEAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEAAAEBAQEBAQEAAAAAAAAAAAABAQEAAAAAAAAAAAEBAQEAAAAAAAAAAAABAQAAAAAAAAAAAAABAQEAAAICAgICAgICAgICAgIAAAICAgICAQEAAAICAgICAgICAgICAgIAAAICAgICAQEAAAAAAAAAAAABAQEAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAQEBAAEBAQEBAAAAAAEAAAAAAQEAAAAAAQEAAAABAQEBAAAAAAAAAAAAAQEAAAAAAQEAAAABAQEBAAAAAAAAAAAAAAAAAAAAAQEAAAABAQEBAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAe++AgIAFgABAQAShwEIAA1DAQkAES0="
const _TEST_MAP_32x16:String = "774BACAQAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAAAAAAAAAAAACAgICAgAAAgIAAAAAAAAAAAEBAAAAAAAAAAAAAAAAAAICAgICAAACAgAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAICAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAgIAAAAAAAAAAAEBAAAAAAAAAAAAAAABAQICAgICAgICAgAAAAAAAAAAAQEAAAAAAAAAAAAAAAEBAgICAgICAgICAAAAAAAAAAABAQAAAAAAAQEBAQEBAQECAgICAgAAAAAAAAAAAAAAAAEBAAAAAAABAQEBAQEBAQICAgICAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAEBAgICAgIAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAQECAgICAgAAAAAAAAEBAAAAAAEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAACAgICAgAAAAAAAAAAAAAAAAEBAAAAAAAAAAAAAAAAAAICAgICAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEB774CEwABWg==4"

const _MAPS = [{
		"title": "Test 1",
		"data": "774BAAgIAQEBAQEBAQEBAQAAAAAAAAEBAAAAAAAAAQEAAAICAAABAQAAAgIAAAEBAAAAAAAAAQEAAAAAAAABAQEBAQEBAQHvvgIDAAYA"
	}, {
		"title": "Test 2",
		"data": "774BABgYAgEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAQEBAAAAAAAAAAABAQEAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEAAAEBAQEBAQEAAAAAAAAAAAABAQEAAAAAAAAAAAEBAQEAAAAAAAAAAAABAQAAAAAAAAAAAAABAQEAAAICAgICAgICAgICAgIAAAICAgICAQEAAAICAgICAgICAgICAgIAAAICAgICAQEAAAAAAAAAAAABAQEAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAQEBAAEBAQEBAAAAAAEAAAAAAQEAAAAAAQEAAAABAQEBAAAAAAAAAAAAAQEAAAAAAQEAAAABAQEBAAAAAAAAAAAAAAAAAAAAAQEAAAABAQEBAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAe++AgsACQABDwAEQw=="
	}, {
		"title": "Test 3",
		"data": "774BABgYBAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAQEBAAAAAAAAAAABAQEAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEAAAEBAQEBAQEAAAAAAAAAAAABAQEAAAAAAAAAAAEBAQEAAAAAAAAAAAABAQAAAAAAAAAAAAABAQEAAAICAgICAgICAgICAgIAAAICAgICAQEAAAICAgICAgICAgICAgIAAAICAgICAQEAAAAAAAAAAAABAQEAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAQEBAAEBAQEBAAAAAAEAAAAAAQEAAAAAAQEAAAABAQEBAAAAAAAAAAAAAQEAAAAAAQEAAAABAQEBAAAAAAAAAAAAAAAAAAAAAQEAAAABAQEBAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAe++AgIAFgABAQAShwEIAA1DAQkAES0="
	}, {
		"title": "Test 32x16",
		"data": "774BACAQAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAAAAAAAAAAAACAgICAgAAAgIAAAAAAAAAAAEBAAAAAAAAAAAAAAAAAAICAgICAAACAgAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAICAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAgIAAAAAAAAAAAEBAAAAAAAAAAAAAAABAQICAgICAgICAgAAAAAAAAAAAQEAAAAAAAAAAAAAAAEBAgICAgICAgICAAAAAAAAAAABAQAAAAAAAQEBAQEBAQECAgICAgAAAAAAAAAAAAAAAAEBAAAAAAABAQEBAQEBAQICAgICAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAEBAgICAgIAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAQECAgICAgAAAAAAAAEBAAAAAAEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAACAgICAgAAAAAAAAAAAAAAAAEBAAAAAAAAAAAAAAAAAAICAgICAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEB774CEwABWg==4"
	}
]

enum AppState { Game, Editor }

var debugDegrees:float = 0
var debug_int:int = 0
var debugV3_1:Vector3 = Vector3()
var debugV3_2:Vector3 = Vector3()

onready var _menus:CanvasLayer = $static_menus
#onready var _menus:Control = $static_menus/menu
#onready var _title:Label = $CanvasLayer/title
onready var _debug_text:Label = $static_menus/debug/debug_text
onready var _debug_text_2:Label = $static_menus/debug/debug_text2
onready var _mouseLock:MouseLock = $mouse_lock

var playerDebug:String = ""

var _state = AppState.Game
var _camera:Camera = null
var _emptyTrans:Transform = Transform.IDENTITY
var _url:String = ""
var _paramStr:String = ""
var _masterBusId:int = -1
var _gameBusId:int = -1
var _bgmBusId:int = -1

var _inputOn:bool = false
var isRebinding:bool = false

# current map being played or edited.
var _mapDef:MapDef = null
var _pendingMapDef:MapDef = null

func _ready() -> void:
	self.pause_mode = PAUSE_MODE_PROCESS
	print("Main service start")#
	_masterBusId = AudioServer.get_bus_index("Master")
	_gameBusId = AudioServer.get_bus_index("game")
	_bgmBusId = AudioServer.get_bus_index("bgm")
	print("Master bus index: " + str(_masterBusId))
	add_to_group(Config.GROUP)
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	set_input_off()
	
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
	
	_debug_text_2.text = "Fauxoom PRE-ALPHA"
	# if _web_mode():
	# 	_debug_text_2.text += "URL: " + _url + "\n"
	# else:
		# _debug_text_2.text += "CmdLine: " + str(OS.get_cmdline_args().join(", ")) + "\n"
		# _debug_text_2.text += "Exe path: " + OS.get_executable_path() + "\n"
		# _debug_text_2.text += "Platform: " + OS.get_name() + "\n"
	# _debug_text_2.text += "ESCAPE or TAB to toggle mouse capture\n"
	# _debug_text_2.text += "WASD - move | Mouse - aim/shoot\n"
	# _debug_text_2.text += "1,2,3,4,5 - Weapon select\n"
	# _debug_text_2.text += "Build time: 2021/1/3 19:22\n"

	# broadcast change if file load failed, have to give everyone the default
	# if !load_cfg(_DEFAULT_CFG_NAME):
	# 	broadcast_cfg_change()

func _process(_delta) -> void:

	_debug_text.text = "FPS: " + str(Engine.get_frames_per_second()) + "\n"
#	var time = OS.get_time()
#	_debug_text.text += str(time.hour) + ":" + str(time.minute) + ":" + str(time.second) + "\n"
#	var ratio:Vector2 = ZqfUtils.get_window_to_screen_ratio()
#	_debug_text.text += "Window/Scr ratio: " + str(ratio) + "\n"
#	_debug_text.text += playerDebug + "\n"
#	_debug_text.text = "Vec 1: " + str(debugV3_1) + "\n"
#	_debug_text.text += "Vec 2: " + str(debugV3_2) + "\n"
#	_debug_text.text += "Degrees: " + str(debugDegrees) + "\n"
#	_debug_text.text += "Index " + str(debug_int) + "\n"

func get_menu_keycode() -> int:
	var menuCode = KEY_ESCAPE
	if _web_mode():
		menuCode = KEY_TAB
	return menuCode

func _input(_event: InputEvent) -> void:
	if isRebinding:
		return
	var menuCode = get_menu_keycode()
	if _event is InputEventKey && _event.scancode == menuCode && _event.pressed && !_event.echo:
		if _inputOn:
			print("Toggle menu on")
			set_input_off()
		# else:
		# 	print("Toggle menu off")
		# 	set_input_on()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		print("MAIN - focus in")
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		print("MAIN - focus out")
		# set_input_off()

func _parse_url_options(optionsStr:String) -> void:
	# eg ?foo=bar&a=b
	print("Parse URL options " + str(optionsStr))

func config_changed(_cfg:Dictionary) -> void:
	_apply_window_settings()
	_refresh_audio_volumes(_cfg.s_sfx, _cfg.s_bgm)
	# save_cfg(cfg, _DEFAULT_CFG_NAME)

func _apply_window_settings() -> void:
	print("Apply window settings")
	OS.window_fullscreen = Config.cfg.r_fullscreen

func _set_bus_volume_percent(busIndex:int, percentage:float) -> void:
	var level:float = percentage / 100.0
	var maxDb:float = 0
	var minDb:float = -40
	var val:float = minDb * (1 - level) + (maxDb * level)
	AudioServer.set_bus_volume_db(busIndex, val)

func _refresh_audio_volumes(_sndVolume:float, _bgmVolume:float) -> void:
	_set_bus_volume_percent(_gameBusId, _sndVolume)
	_set_bus_volume_percent(_bgmBusId, _bgmVolume)
	# var level:float = _sndVolume / 100.0
	# var maxDb:float = 0
	# var minDb:float = -40
	# var val:float = minDb * (1 - level) + (maxDb * level)
	# print("Set sfx db to " + str(val) + " from level " + str(level))
	# AudioServer.set_bus_volume_db(_gameBusId, val)
 
func get_map() -> MapDef:
	if _mapDef == null:
		_mapDef = MapEncoder.b64_to_map(_TEST_MAP)
		_mapDef = MapEncoder.b64_to_map(_TEST_MAP_2)
		# _mapDef = MapEncoder.empty_map(8, 8)
		# _mapDef.set_all(1)
	return _mapDef

func set_pending_map(newPendingMap:MapDef) -> void:
	if newPendingMap == null:
		return
	_pendingMapDef = newPendingMap

func on_game_play_level() -> void:
	_mapDef = _pendingMapDef
	_state = AppState.Game
	var _foo = get_tree().change_scene(_GAME_SCENE_PATH)

func on_game_edit_level() -> void:
	_mapDef = _pendingMapDef
	_state = AppState.Editor
	var _foo = get_tree().change_scene(_EDITOR_SCENE_PATH)

func set_input_on() -> void:
	_inputOn = true
	_menus.off()
	# MouseLock.remove_claim(get_tree(), "main_menu")
	_mouseLock.on_remove_mouse_claim("main_menu")
	var grp = Groups.GAME_GROUP_NAME
	var fn = Groups.GAME_FN_UNPAUSE
	get_tree().call_group(grp, fn)

func set_input_off() -> void:
	_inputOn = false
	_menus.on()
	# MouseLock.add_claim(get_tree(), "main_menu")
	_mouseLock.on_add_mouse_claim("main_menu")
	var grp = Groups.GAME_GROUP_NAME
	var fn = Groups.GAME_FN_PAUSE
	get_tree().call_group(grp, fn)

func _web_mode() -> bool:
	return (OS.get_name() == "HTML5")

func get_input_on() -> bool:
	return _inputOn

func _refresh_input_on() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if _inputOn:
			set_input_off()
		else:
			set_input_on()

func console_on_exec(txt:String, _tokens:PoolStringArray) -> void:
	print("EXEC " + txt)
	if _tokens.size() >= 2:
		if _tokens[0] == "map":
			var path:String = "res://maps/" + _tokens[1] + ".tscn"
			change_map(path)
	if txt == "quit" || txt == "exit":
		get_tree().quit()
	if txt == "info":
		print("OS name: " + OS.get_name())
	if _tokens[0] == "cfg_save":
		var fileName:String = Config.cfgName
		if _tokens.size() >= 2:
			fileName = _tokens[1]
		Config.save_cfg(fileName)
	if _tokens[0] == "cfg_load":
		var fileName:String = Config.cfgName
		if _tokens.size() >= 2:
			fileName = _tokens[1]
		if !Config.load_cfg(fileName):
			print("Failed to load cfg")

func change_map(path:String) -> void:
	var grp:String = Groups.GAME_GROUP_NAME
	var fn:String = Groups.GAME_FN_MAP_CHANGE
	get_tree().call_group(grp, fn)
	var _foo = get_tree().change_scene(path)
	set_input_on()

# a globally accessible camera is required for 3D sprite frame selection
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
