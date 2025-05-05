extends Node3D

const Enums = preload("res://src/enums.gd")

const _GAME_SCENE_PATH = "res://maps/grid_map.tscn"
const _EDITOR_SCENE_PATH = "res://maps/level_editor.tscn"

# const _DEFAULT_CFG_NAME = "fauxoom"

# the first concept for this project was a browser based game with a level editor...
# load of stuff in this class is based around a 'gridmap' and loading these base64 strings
# into map data. This stuff is defunct now, but I've not bothered cleaning it out yet.
# sorry.

# smaller test
const _TEST_MAP:String = "774BAAgIAQEBAQEBAQEBAQAAAAAAAAEBAAAAAAAAAQEAAAICAAABAQAAAgIAAAEBAAAAAAAAAQEAAAAAAAABAQEBAQEBAQHvvgIDAAYA"

# 24x24 test
# const _TEST_MAP_2:String = "774BABgYBAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAAAAAAABAQEBAQEBAQEBAQEBAQEAAAAAAAAAAAABAQEBAQEBAQEBAQEBAQEAAAICAgICAgICAgIBAQEBAQEBAQEBAQEAAAICAgICAgICAgIBAQEBAQEBAQEBAQEAAAAAAAAAAAABAQEBAQEBAQEBAQEBAQEAAAAAAAAAAAABAQEBAQEBAQEBAQEBAQEBAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAABAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAe++AgIAFgABBQASAAEJAA4AAQkAEQA="
const _TEST_MAP_2:String = "774BABgYAgEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAQEBAAAAAAAAAAABAQEAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEAAAEBAQEBAQEAAAAAAAAAAAABAQEAAAAAAAAAAAEBAQEAAAAAAAAAAAABAQAAAAAAAAAAAAABAQEAAAICAgICAgICAgICAgIAAAICAgICAQEAAAICAgICAgICAgICAgIAAAICAgICAQEAAAAAAAAAAAABAQEAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAQEBAAEBAQEBAAAAAAEAAAAAAQEAAAAAAQEAAAABAQEBAAAAAAAAAAAAAQEAAAAAAQEAAAABAQEBAAAAAAAAAAAAAAAAAAAAAQEAAAABAQEBAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAe++AgsACQABDwAEQw=="
const _TEST_MAP_3:String = "774BABgYBAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAQEBAAAAAAAAAAABAQEAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEAAAEBAQEBAQEAAAAAAAAAAAABAQEAAAAAAAAAAAEBAQEAAAAAAAAAAAABAQAAAAAAAAAAAAABAQEAAAICAgICAgICAgICAgIAAAICAgICAQEAAAICAgICAgICAgICAgIAAAICAgICAQEAAAAAAAAAAAABAQEAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAQEBAAEBAQEBAAAAAAEAAAAAAQEAAAAAAQEAAAABAQEBAAAAAAAAAAAAAQEAAAAAAQEAAAABAQEBAAAAAAAAAAAAAAAAAAAAAQEAAAABAQEBAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAe++AgIAFgABAQAShwEIAA1DAQkAES0="
const _TEST_MAP_32x16:String = "774BACAQAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAAAAAAAAAAAACAgICAgAAAgIAAAAAAAAAAAEBAAAAAAAAAAAAAAAAAAICAgICAAACAgAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAICAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAgIAAAAAAAAAAAEBAAAAAAAAAAAAAAABAQICAgICAgICAgAAAAAAAAAAAQEAAAAAAAAAAAAAAAEBAgICAgICAgICAAAAAAAAAAABAQAAAAAAAQEBAQEBAQECAgICAgAAAAAAAAAAAAAAAAEBAAAAAAABAQEBAQEBAQICAgICAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAEBAgICAgIAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAQECAgICAgAAAAAAAAEBAAAAAAEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAACAgICAgAAAAAAAAAAAAAAAAEBAAAAAAAAAAAAAAAAAAICAgICAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEB774CEwABWg==4"

#const _MAPS = [{
#		"title": "Test 1",
#		"data": "774BAAgIAQEBAQEBAQEBAQAAAAAAAAEBAAAAAAAAAQEAAAICAAABAQAAAgIAAAEBAAAAAAAAAQEAAAAAAAABAQEBAQEBAQHvvgIDAAYA"
#	}, {
#		"title": "Test 2",
#		"data": "774BABgYAgEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAQEBAAAAAAAAAAABAQEAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEAAAEBAQEBAQEAAAAAAAAAAAABAQEAAAAAAAAAAAEBAQEAAAAAAAAAAAABAQAAAAAAAAAAAAABAQEAAAICAgICAgICAgICAgIAAAICAgICAQEAAAICAgICAgICAgICAgIAAAICAgICAQEAAAAAAAAAAAABAQEAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAQEBAAEBAQEBAAAAAAEAAAAAAQEAAAAAAQEAAAABAQEBAAAAAAAAAAAAAQEAAAAAAQEAAAABAQEBAAAAAAAAAAAAAAAAAAAAAQEAAAABAQEBAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAe++AgsACQABDwAEQw=="
#	}, {
#		"title": "Test 3",
#		"data": "774BABgYBAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAQEBAAAAAAAAAAABAQEAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEAAAEBAQEBAQEAAAAAAAAAAAABAQEAAAAAAAAAAAEBAQEAAAAAAAAAAAABAQAAAAAAAAAAAAABAQEAAAICAgICAgICAgICAgIAAAICAgICAQEAAAICAgICAgICAgICAgIAAAICAgICAQEAAAAAAAAAAAABAQEAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAQEBAAEBAQEBAAAAAAEAAAAAAQEAAAAAAQEAAAABAQEBAAAAAAAAAAAAAQEAAAAAAQEAAAABAQEBAAAAAAAAAAAAAAAAAAAAAQEAAAABAQEBAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAe++AgIAFgABAQAShwEIAA1DAQkAES0="
#	}, {
#		"title": "Test 32x16",
#		"data": "774BACAQAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQAAAAAAAAAAAAAAAAACAgICAgAAAgIAAAAAAAAAAAEBAAAAAAAAAAAAAAAAAAICAgICAAACAgAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAICAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAgIAAAAAAAAAAAEBAAAAAAAAAAAAAAABAQICAgICAgICAgAAAAAAAAAAAQEAAAAAAAAAAAAAAAEBAgICAgICAgICAAAAAAAAAAABAQAAAAAAAQEBAQEBAQECAgICAgAAAAAAAAAAAAAAAAEBAAAAAAABAQEBAQEBAQICAgICAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAEBAgICAgIAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAQECAgICAgAAAAAAAAEBAAAAAAEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAACAgICAgAAAAAAAAAAAAAAAAEBAAAAAAAAAAAAAAAAAAICAgICAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEB774CEwABWg==4"
#	}
#]

var debugDegrees:float = 0
var debug_int:int = 0
var debugV3_1:Vector3
var debugV3_2:Vector3

@onready var _menus:CanvasLayer = $static_menus
#@onready var _menus:Control = $static_menus/menu
#@onready var _title:Label = $CanvasLayer/title
@onready var _debugTextNW:Label = $static_menus/debug/debug_text
@onready var _debugTextNE:Label = $static_menus/debug/debug_text2
@onready var _mouseLock:MouseLock = $mouse_lock

var _debugNWMode:int = 0
var _debugNEMode:int = 0

var playerDebug:String = ""

var _state = Enums.AppState.Game
var _pendingState = Enums.AppState.Game
var _camera:Camera3D = null
var _emptyTrans:Transform3D = Transform3D.IDENTITY
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

var _currentMapName:String = ""
var _currentEntities:String = ""

func _ready() -> void:

	self.process_mode = Node.PROCESS_MODE_ALWAYS
	print("Main service start")
	_masterBusId = AudioServer.get_bus_index("Master")
	_gameBusId = AudioServer.get_bus_index("game")
	_bgmBusId = AudioServer.get_bus_index("bgm")
	print("Master bus index: " + str(_masterBusId))
	add_to_group(Config.GROUP)
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	# off - open main menu
	#set_input_off()
	set_input_on()

	EntityEditor.disable()
	
	#if OS.has_feature("JavaScript"):
	#	print("JS available")
	#	# get full url
	#	var js_result = JavaScript.eval("""
	#		var js_result;
	#		js_result = window.location.href;
	#	""")
	#	if js_result is String:
	#		_url = js_result
	#	else:
	#		print("ERROR: JS url result was not a string!")
	#	# get params
	#	js_result = JavaScript.eval("""
	#		var js_result;
	#		js_result = window.location.search
	#	""")
	#	# print("URL location: " + str(js_result))
	#	_parse_url_options(js_result)
	#else:
	#	print("JS not available")

func _process(_delta) -> void:

	_debugTextNW.text = "FPS: " + str(Engine.get_frames_per_second()) + "\n"
	#	var time = OS.get_time()
	#	_debugTextNW.text += str(time.hour) + ":" + str(time.minute) + ":" + str(time.second) + "\n"
	#	var ratio:Vector2 = ZqfUtils.get_window_to_screen_ratio()
	#	_debugTextNW.text += "Window/Scr ratio: " + str(ratio) + "\n"
	#	_debugTextNW.text += playerDebug + "\n"
	#	_debugTextNW.text = "Vec 1: " + str(debugV3_1) + "\n"
	#	_debugTextNW.text += "Vec 2: " + str(debugV3_2) + "\n"
	#	_debugTextNW.text += "Degrees: " + str(debugDegrees) + "\n"
	#	_debugTextNW.text += "Index " + str(debug_int) + "\n"
	
	if _debugNEMode == 0:
		_debugTextNE.text = "Fauxoom PRE-ALPHA"
	elif _debugNEMode == 1:
		_debugTextNE.text = AI.get_debug_text()
	# if ZqfUtils.is_web_build()():
	# 	_debugTextNE.text += "URL: " + _url + "\n"
	# else:
		# _debugTextNE.text += "CmdLine: " + str(OS.get_cmdline_args().join(", ")) + "\n"
		# _debugTextNE.text += "Exe path: " + OS.get_executable_path() + "\n"
		# _debugTextNE.text += "Platform: " + OS.get_name() + "\n"
	# _debugTextNE.text += "ESCAPE or TAB to toggle mouse capture\n"
	# _debugTextNE.text += "WASD - move | Mouse - aim/shoot\n"
	# _debugTextNE.text += "1,2,3,4,5 - Weapon select\n"
	# _debugTextNE.text += "Build time: 2021/1/3 19:22\n"

	# broadcast change if file load failed, have to give everyone the default
	# if !load_cfg(_DEFAULT_CFG_NAME):
	# 	broadcast_cfg_change()

func get_app_state() -> int:
	return _state

func is_in_game() -> bool:
	return _state == Enums.AppState.Game

func is_in_editor() -> bool:
	return _state == Enums.AppState.Editor

func get_current_map_name() -> String:
	return _currentMapName

func get_current_entities_file() -> String:
	return _currentEntities

func get_menu_keycode() -> int:
	var menuCode = KEY_ESCAPE
	if ZqfUtils.is_web_build():
		menuCode = KEY_TAB
	return menuCode

func get_entities_directory(embedded:bool) -> String:
	var root:String = "user://ents"
	if embedded:
		if ZqfUtils.is_running_in_editor():
			# if running an editor build look in project files
			root = "./ents"
		else:
			# if exported look in packaged resources
			root = "res://ents"
	return root

func get_entities_file_extension() -> String:
	return ".json"

func build_save_path(fileName, embedded:bool) -> String:
	var root:String = "user://saves"
	var extension:String = get_entities_file_extension()
	if embedded:
		root = "res://saves"
	ZqfUtils.make_dir(root)
	return root + "/" + fileName + extension

func build_entity_file_path(fileName, embedded:bool) -> String:
	var root:String = get_entities_directory(embedded)
	ZqfUtils.make_dir(root)
	var extension:String = get_entities_file_extension()
	return root + "/" + fileName + extension

func _input(_event: InputEvent) -> void:
	if isRebinding:
		return
	var menuCode = get_menu_keycode()
	if _event is InputEventKey && _event.scancode == menuCode && _event.pressed && !_event.echo:
		if _inputOn:
			print("Toggle menu on")
			set_input_off()
		elif !ZqfUtils.is_web_build():
			print("Toggle menu off")
			set_input_on()

#func _notification(what):
#	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
#		print("MAIN - focus in")
#	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
#		print("MAIN - focus out")
#		# set_input_off()

func _parse_url_options(optionsStr:String) -> void:
	# eg ?foo=bar&a=b
	print("Parse URL options " + str(optionsStr))

func config_changed(_cfg:Dictionary) -> void:
	_apply_window_settings()
	_refresh_audio_volumes(_cfg.s_sfx, _cfg.s_bgm)
	# save_cfg(cfg, _DEFAULT_CFG_NAME)

func _apply_window_settings() -> void:
	print("Apply window settings")
	var fs:bool = Config.cfg.r_fullscreen
	var window:int = 0
	if fs && DisplayServer.window_get_mode(window) != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN, window)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED, window)

	var vsync:int = 1 if (Config.cfg.r_vsync == true) else 0
	var curVsync = DisplayServer.window_get_vsync_mode(window)
	if curVsync != vsync:
		DisplayServer.window_set_vsync_mode(vsync, window)


func _set_bus_volume_percent(busIndex:int, percentage:float) -> void:
	if percentage <= 0:
		AudioServer.set_bus_mute(busIndex, true)
	else:
		AudioServer.set_bus_mute(busIndex, false)
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
	_state = Enums.AppState.Game
	var _foo = get_tree().change_scene(_GAME_SCENE_PATH)

func on_game_edit_level() -> void:
	_mapDef = _pendingMapDef
	_state = Enums.AppState.Editor
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

func debug_mode() -> bool:
	return true
	# use this to disable the debugger in proper builds
	#return !OS.has_feature("standalone")

func get_input_on() -> bool:
	return _inputOn

func _refresh_input_on() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if _inputOn:
			set_input_off()
		else:
			set_input_on()

func submit_console_command(txt:String) -> void:
	if txt == null || txt == "":
		return
	var tokens = ZqfUtils.tokenise(txt)
	if tokens.size() == 0:
		return
	print("SUBMIT: " + txt)
	get_tree().call_group(
		Groups.CONSOLE_GROUP_NAME,
		Groups.CONSOLE_FN_EXEC,
		txt, tokens)

func _list_dir(path:String, extension:String) -> void:
	var files = ZqfUtils.get_files_in_directory(path, extension)
	print("Found " + str(files.size()) + " files in " + path)
	for file in files:
		print(file)

func console_on_exec(txt:String, _tokens:PackedStringArray) -> void:
	if _tokens.size() == 0:
		return
	if txt == "map_path":
		print("Map path: " + get_tree().current_scene.filename)
		var map = get_current_map_name()
		var ents = get_current_entities_file()
		print("Scene/Entities: " + map +" / " + ents)
	elif txt == "quit" || txt == "exit":
		get_tree().quit()
	elif txt == "info":
		print("OS name: " + OS.get_name())
	elif txt == "mouse":
		get_tree().call_group(MouseLock.GROUP_NAME, MouseLock.DEBUG_LOCK_FN)
	elif _tokens[0] == "cfg_save":
		var fileName:String = Config.cfgName
		if _tokens.size() >= 2:
			fileName = _tokens[1]
		Config.save_cfg(fileName)
	elif _tokens[0] == "cfg_load":
		var fileName:String = Config.cfgName
		if _tokens.size() >= 2:
			fileName = _tokens[1]
		if !Config.load_cfg(fileName):
			print("Failed to load cfg")
	elif _tokens[0] == "split_test":
		var testStr:String = "11,22,33,44,55,66"
		if _tokens.size() >= 2:
			testStr = _tokens[1]
		var result:int = ZqfUtils.read_csv_int(testStr, 2, 99)
		print("Csv Split result: " + str(result))
	elif _tokens[0] == "check_file":
		if _tokens.size() < 2:
			print("Specify a file path!")
			return
		var path = _tokens[1]
		var exists:bool = ZqfUtils.does_file_exist(path)
		print(path + " exists: " + str(exists))
	elif _tokens[0] == "list_entfiles":
		print("----- Files in app folder -----")
		_list_dir("ents", ".json")
		print("----- Files in user folder -----")
		_list_dir("user://ents", ".json")
	elif _tokens[0] == "list_dir":
		if _tokens.size() < 3:
			print("List files in dir: list_dir <path> <extension>")
			return
		_list_dir(_tokens[1], _tokens[2])
		return

func _map_name_to_path(name:String) -> String:
	return "res://maps/" + name + "/" + name + ".tscn"

# returns false if change failed
func change_scene(mapName:String, _entityFileName, _appState) -> bool:
	# is the new scene the same as the one we are on?
	var curScene = get_tree().get_current_scene().filename
	var curEvents = get_current_entities_file()

	# if curScene == mapName:
	# 	print("Current Scene" + str(curScene) + " matches requested " + str(mapName))
	# 	# update state and drop out
	# 	if _state != _appState:
	# 		_state = _appState
	# 		print("Changing App State: " + str(_state))
	# 	# if the entity file has changed we should still emit a scene
	# 	# change event
	# 	# if curEvents != _entityFileName || _appState != _state:
	# 	# 	var grp:String = Groups.GAME_GROUP_NAME
	# 	# 	var fn:String = Groups.GAME_FN_MAP_CHANGE
	# 	# 	get_tree().call_group(grp, fn)
	# 	return true
	
	# no scene match
	print("Current Scene" + str(curScene) + " does not match requested " + str(mapName))

	var path:String = _map_name_to_path(mapName)
	if !ResourceLoader.exists(path):
		print("Map " + path + " not found")
		return false
	_currentMapName = mapName
	_currentEntities = _entityFileName
	if _state != _appState:
		_state = _appState
		print("Changing App State: " + str(_state))
	var grp:String = Groups.GAME_GROUP_NAME
	var fn:String = Groups.GAME_FN_MAP_CHANGE
	get_tree().call_group(grp, fn)
	var _foo = get_tree().change_scene(path)
	set_input_on()
	return true

# a globally accessible camera is required for 3D sprite frame selection
func set_camera(cam:Camera3D) -> void:
	if cam == null:
		return
	_camera = cam

func clear_camera(cam:Camera3D) -> void:
	if cam != null && _camera == cam:
		_camera = null

func get_camera_pos() -> Transform3D:
	if _camera != null:
		return _camera.global_transform
	return _emptyTrans
