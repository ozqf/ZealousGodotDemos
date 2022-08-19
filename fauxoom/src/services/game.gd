extends Spatial
class_name GameController

const Enums = preload("res://src/enums.gd")

const MOUSE_CLAIM:String = "gameUI"

const START_SAVE_FILE_NAME:String = "start"
const CHECKPOINT_SAVE_FILE_NAME:String = "checkpoint"
const QUICK_SAVE_FILE_NAME:String = "quick"

###########################
var _player_t = preload("res://prefabs/player.tscn")
# var _gib_t = preload("res://prefabs/gib.tscn")
var _head_gib_t = preload("res://prefabs/player_gib.tscn")

var _hitInfo_type = preload("res://src/defs/hit_info.gd")
var _tagSet_t = preload("res://src/defs/ent_tag_set.gd")
var _mobHealthInfo_t = preload("res://src/defs/mob_health_info.gd")
var _corpse_spawn_info_t = preload("res://src/defs/corpse_spawn_info.gd")

# when saw blade is launched, input handling is passed onto the projectile
# the projectile is recycled, if we don't have one, create one and reuse it
var prj_player_saw_t = preload("res://prefabs/projectiles/prj_player_saw.tscn")

###########################
var _entRoot:Entities = null
var _dynamicRoot:Spatial = null

onready var _factory:PrefabFactory = $prefab_factory
onready var _events = $map_events
onready var _pregameUI:Control = $game_state_overlay/pregame
onready var _completeUI:Control = $game_state_overlay/complete
onready var _deathUI:Control = $game_state_overlay/death
onready var _hintContainer:Control = $game_state_overlay/hint_text
onready var _hintLabelTop:Label = $game_state_overlay/hint_text/hint_label_top
onready var _screenFade:ColorRect = $game_state_overlay/screen_fade

onready var _camera:AttachableCamera = $attachable_camera
var _defaultEnvironment:Environment = null
var _environment:String = ""
var _environments = ZqfUtils.EMPTY_DICT

var debuggerMode = Enums.DebuggerMode.Deathray
var debuggerAtkMode:String = "column"
var debuggerOpen:bool = false

# contains current skill settings
var _skill:int = 2
# next skill setting to select on map change
var _pendingSkill:int = 2

var _skills = []

var _state = Enums.GameState.Pregame
var _gameMode = Enums.GameMode.King
var _pendingGameMode = Enums.GameMode.King

var allowQuickSwitching:bool = true
var quickSwitchTime:float = 0.5
var hyperLevel:int = 0

var _hasPlayerStart:bool = false
var _playerOrigin:Transform = Transform.IDENTITY

var _debugMob = null

# live player
var _player:Player = null
var _pendingSaveName:String = ""
var _pendingLoadDict:Dictionary = {}
var _pendingLoadDictIsSave:bool = false
# this must default to true so that it triggers on initial startup
var _justLoaded:bool = true
# ditto, in this case it is used to detect that a new map was started
var _freshMap:bool = true

var _hintTextTick:float = 0

var _emptyTargetInfo:Dictionary = {
	id = 0,
	position = Vector3(),
	yawDegrees = 0
}

# func set_game_mode(mode:int) -> void:
# 	_gameMode = mode

func _ready() -> void:
	print("Game singleton init")
	_entRoot = Ents
	add_to_group(Config.GROUP)
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	add_to_group(Groups.GAME_GROUP_NAME)
	_refresh_overlay()
	var _result = $game_state_overlay/death/menu/reset.connect("pressed", self, "on_clicked_reset")
	_result = $game_state_overlay/death/menu/checkpoint.connect("pressed", self, "on_clicked_checkpoint")
	_result = $game_state_overlay/complete/menu/reset.connect("pressed", self, "on_clicked_reset")
	Main.set_camera(_camera)
	_hintContainer.visible = false

	_skills = get_node("skills").get_children()
	
	_defaultEnvironment = _camera.environment
	_factory.prefab_factory_init(_dynamicRoot, _entRoot)

	# config_changed(Config.cfg)

	print("Game set default skill - " + str(get_skill().label))

	# does checkpoint exist?
	# if so we can have a 'continue' option
	if ZqfUtils.does_file_exist(CHECKPOINT_SAVE_FILE_NAME):
		print("Checkpoint file found")
	else:
		print("No checkpoint file found")

func get_factory() -> PrefabFactory:
	return _factory

func set_pending_load_dict(dict:Dictionary, isSaveGame:bool) -> void:
	_pendingLoadDict = dict
	_pendingLoadDictIsSave = isSaveGame

func new_hit_info() -> HitInfo:
	return _hitInfo_type.new()

func new_tag_set() -> EntTagSet:
	return _tagSet_t.new()

func new_mob_health_info() -> MobHealthInfo:
	return _mobHealthInfo_t.new()

func new_corpse_spawn_info() -> CorpseSpawnInfo:
	return _corpse_spawn_info_t.new()

func config_changed(_cfg:Dictionary) -> void:
	print("Game - read fov")
	_camera.fov = _cfg.r_fov
	var target:int = _cfg.r_fpsTarget
	if target <= 0:
		target = 0
	elif target < 60:
		target = 60
	Engine.set_target_fps(target)

func write_save_file(fileName:String) -> void:
	var path = Main.build_save_path(fileName, false)
	save_game(path)

func show_hint_text(txt:String) -> void:
	# print("Show hint text" + txt)
	_hintTextTick = 3
	_hintLabelTop.text = txt
	_hintContainer.visible = true

func _process_gameplay(_delta:float) -> void:
	
	if get_tree().paused == false:
		if _hintTextTick <= 0:
			_hintContainer.visible = false
		else:
			_hintTextTick -= _delta
	# if _state == Enums.GameState.Pregame && _hasPlayerStart:
	# 	begin_game()
	_check_for_pending_save()
	if _check_for_pending_load_dict():
		pass
	elif _justLoaded:
		_justLoaded = false
		print("Just loaded fresh map - writing reset save")
		# tell initial spawns to run
		get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_RUN_MAP_SPAWNS)

func _process_editor(_delta:float) -> void:
	_check_for_pending_save()
	if _check_for_pending_load_dict():
		# we've just loaded entities from a file - inform the editor
		EntityEditor.refresh_entities()
		pass
	elif _justLoaded:
		_justLoaded = false
		print("Game - editor mode just loaded")
	pass

func _process(_delta:float) -> void:
	if Main.is_in_editor():
		_process_editor(_delta)
	elif Main.is_in_game():
		_process_gameplay(_delta)
	else:
		print("GAME - unknown App state")

func _check_for_pending_save() -> void:
	if _pendingSaveName != "":
		print("Have pending save " + _pendingSaveName)
		# if we are writing a map start save, write the checkpoint too!
		if _pendingSaveName == START_SAVE_FILE_NAME:
			write_save_file(CHECKPOINT_SAVE_FILE_NAME)
		write_save_file(_pendingSaveName)
		_pendingSaveName = ""

# returns true if ent data was loaded
func _check_for_pending_load_dict() -> bool:
	if _pendingLoadDict:
		print("Have pending ents - loading")
		if _freshMap:
			_freshMap = false
			# queue writing start save
			_pendingSaveName = START_SAVE_FILE_NAME
			pass
		# we may have just switched maps but have entities to load.
		# make sure to not trigger the initial spawns events
		# _justLoaded = false
		# clear pending and run
		var dict = _pendingLoadDict
		# make sure to clear the dict now!
		_pendingLoadDict = {}
		_cleanup_temp_entities()
		_events.clear()
		load_save_dict(dict)
		return true
	return false

# func get_entity_prefab(name:String) -> Object:
# 	if name == null || name == "":
# 		push_error("entity prefab name is null or empty")
# 	return _entRoot.get_prefab_def(name).prefab

func _cleanup_temp_entities() -> void:
	get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_CLEANUP_TEMP_ENTS)

# disable of menu HAS to be triggered from here in web mode
func _input(_event) -> void:
	pass
	# if _event is InputEventKey:
	# 	if !Main.get_input_on():
	# 		# menu is up, abort
	# 		return
	# 	if _state == Enums.GameState.Pregame:
	# 		if !_hasPlayerStart:
	# 			Main.set_input_off()
	# 			return
	# 		elif Input.is_action_just_pressed("ui_select"):
	# 			begin_game()
		# var a = _state == Enums.GameState.Pregame
		# var b = Input.is_action_just_pressed("ui_select")
		# var c = Main.get_input_on()
		# var d = _hasPlayerStart
		# if a && b && c && d:
		# 	begin_game()

func get_dynamic_parent() -> Spatial:
	if _dynamicRoot != null:
		return _dynamicRoot
	return _entRoot

func get_skill() -> Skill:
	return _skills[_skill] as Skill

func get_events() -> Object:
	return _events

func on_restart_map() -> void:
	Main.submit_console_command("load start")

func on_clicked_retry() -> void:
	Main.submit_console_command("load checkpoint")

func on_clicked_reset() -> void:
	Main.submit_console_command("load start")

func on_clicked_checkpoint() -> void:
	Main.submit_console_command("load checkpoint")

func _refresh_overlay() -> void:
	if Main.is_in_game():
		_refresh_gameplay_overlay()
	elif Main.is_in_editor():
		_refresh_editor_overlay()
		var grp:String = HudObjectives.GROUP_NAME
		var fn:String = HudObjectives.FN_CLEAR_OBJECTIVES
		get_tree().call_group(grp, fn)
	else:
		print("GAME - refresh overlay - unknown app state")

func _refresh_gameplay_overlay() -> void:
	
	if _state == Enums.GameState.Pregame:
		_pregameUI.visible = _hasPlayerStart
		_completeUI.visible = false
		_deathUI.visible = false
		# _screenFade.visible = true
		# MouseLock.add_claim(get_tree(), MOUSE_CLAIM)
		MouseLock.remove_claim(get_tree(), MOUSE_CLAIM)
	elif _state == Enums.GameState.Won:
		_pregameUI.visible = false
		_completeUI.visible = true
		_deathUI.visible = false
		# _screenFade.visible = true
		MouseLock.add_claim(get_tree(), MOUSE_CLAIM)
	elif _state == Enums.GameState.Lost:
		_pregameUI.visible = false
		_completeUI.visible = false
		# _screenFade.visible = true
		_deathUI.visible = true
		MouseLock.add_claim(get_tree(), MOUSE_CLAIM)
	else:
		# oooh, gameplay. Good to have some of that
		_pregameUI.visible = false
		_completeUI.visible = false
		_screenFade.visible = false
		_deathUI.visible = false
		MouseLock.remove_claim(get_tree(), MOUSE_CLAIM)

func _refresh_editor_overlay() -> void:
	_pregameUI.visible = false
	_completeUI.visible = false
	_screenFade.visible = false
	_deathUI.visible = false
	MouseLock.remove_claim(get_tree(), MOUSE_CLAIM)

func _apply_pending_mode() -> void:
	_gameMode = _pendingGameMode

#func _build_save_path(fileName, embedded:bool) -> String:
#	var root:String = "user://saves"
#	var extension:String = ".json"
#	if embedded:
#		root = "res://saves"
#	ZqfUtils.make_dir(root)
#	return root + "/" + fileName + extension
#
#func _build_entity_file_path(fileName, embedded:bool) -> String:
#	var root:String = "user://ents"
#	var extension:String = ".json"
#	if embedded:
#		if ZqfUtils.is_running_in_editor():
#			# if running an editor build look in project files
#			root = "./ents"
#		else:
#			# if exported look in packaged resources
#			root = "res://ents"
#	ZqfUtils.make_dir(root)
#	return root + "/" + fileName + extension

func _load_entities(_fileName, _fileSource, appState) -> bool:
	if appState != Enums.AppState.Game && appState != Enums.AppState.Editor:
		appState = Enums.AppState.Game
	var path:String = ""
	var embeddedPath:String = Main.build_entity_file_path(_fileName, true)
	var userPath:String = Main.build_entity_file_path(_fileName, false)
	# first try user directory if we're allowed
	if _fileSource == Enums.FileSource.UserOnly || _fileSource == Enums.FileSource.EmbeddedAndUser:
		if ZqfUtils.does_file_exist(userPath):
			path = userPath
	# did we not get a path?
	if path == "":
		if _fileSource != Enums.FileSource.UserOnly:
			# we're allowed to look in embedded resources
			if ZqfUtils.does_file_exist(embeddedPath):
				path = embeddedPath
			else:
				var msg = "File " + _fileName + " not found in resources (" + embeddedPath + ")"
				push_error(msg)
				return false
	
	if path == "":
		# still nothing? Give up
		var msg = "File " + _fileName + " not found in resources (" + embeddedPath
		msg += ") or user dir: (" + userPath + ")"
		push_error(msg)
		return false
	
	# okay, do stuff
	var data:Dictionary = ZqfUtils.load_dict_json_file(path)
	if !data:
		push_error("Failed to create dictionary from " + path)
		return false
	# stage entity load for next frame
	_pendingLoadDict = data
	# cleanup current entities
	_cleanup_temp_entities()

	# data.entFilePath will not be set on an entities file, only
	# a savegame!
	Main.change_scene(data.mapName, _fileName, appState)

	return true

func _exec_file_load(fileName, appState, fileIsEmbedded:bool) -> void:
	var path:String
	if appState == Enums.AppState.Game:
		path = Main.build_save_path(fileName, fileIsEmbedded)
	else:
		path = Main.build_entity_file_path(fileName, fileIsEmbedded)
	var data:Dictionary = ZqfUtils.load_dict_json_file(path)
	if !data:
		return
	_pendingLoadDict = data
	_cleanup_temp_entities()
	print("Set pending ents dict from " + path)
	var curScene = get_tree().get_current_scene().filename
	var newScene = data.mapName
	var newEntFile = ""
	if data.has("entsFileName"):
		newEntFile = data.entsFileName
	if curScene != newScene:
		print("Save is for a different map...")
		Main.change_scene(data.mapName, "", appState)
	else:
		print("Save is same map - no change")

func console_on_exec(_txt:String, _tokens:PoolStringArray) -> void:
	var numTokens:int = _tokens.size()
	var first:String = _tokens[0]
	if first == "reset":
		print("Game - reset")
		_cleanup_temp_entities()
		reset_game()
	elif first == "gamemode":
		if numTokens < 2:
			print("Set gamemode - need second param")
			return
		var newModeName = _tokens[1]
		if newModeName == "king":
			_pendingGameMode = Enums.GameMode.King
		else:
			_pendingGameMode = Enums.GameMode.Classic
		print("Set Game Mode " + str(newModeName) + ": " + str(_pendingGameMode))
	elif _txt == "killai":
		print("Killing all AI")
		get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_KILL_AI)
	elif first == "current_map":
		print("Playing map " + get_tree().get_current_scene().filename)
	elif first == "play":
		print(">>> play '" + _txt + "' <<<")
		var fileName = "catacombs_entity_test"
		if numTokens > 1:
			fileName = _tokens[1]
		_apply_pending_mode()
		if !_load_entities(fileName, Enums.FileSource.EmbeddedAndUser, Enums.AppState.Game):
			print("Play from file failed")
		else:
			_freshMap = true
	elif first == "edit":
		var fileName
		if numTokens > 1:
			fileName = _tokens[1]
		elif Main.get_current_entities_file() != "":
			fileName = Main.get_current_entities_file()
		else:
			fileName = "sandbox_01"
		if !_load_entities(fileName, Enums.FileSource.EmbeddedAndUser, Enums.AppState.Editor):
			print("Edit from file failed")
	elif first == "new":
		var fileName = "sandbox"
		if numTokens > 1:
			fileName = _tokens[1]
		if !Main.change_scene(fileName, "", Enums.AppState.Editor):
			print("New entities from scene failed")
		pass
	elif first == "map":
		var fileName = "sandbox"
		if numTokens > 1:
			fileName = _tokens[1]
		if !Main.change_scene(fileName, "", Enums.AppState.Game):
			print("Map load failed")
	elif first == "save":
		var fileName:String = QUICK_SAVE_FILE_NAME
		if numTokens >= 2:
			fileName = _tokens[1]
		_pendingSaveName = fileName
	elif first == "load":
		var fileName:String = QUICK_SAVE_FILE_NAME
		if numTokens >= 2:
			fileName = _tokens[1]
		_exec_file_load(fileName, Enums.AppState.Game, false)
	elif first == "skill":
		if numTokens == 1:
			var sk:Skill = get_skill()
			print("Current skill is" + str(sk.name) + " (" + str(sk.label) + ")")
		else:
			var newSkill:int = int(_tokens[1])
			if newSkill < 0 || newSkill >= _skills.size():
				print("Requested skill " + str(newSkill) + " is out of bounds")
				return
			else:
				_pendingSkill = newSkill
				print("Set pending skill " + str(_pendingSkill))

###############
# save/load state
###############

func load_save_dict(dict:Dictionary) -> void:
	if _player:
		# have to free immediately or new player will be spawned
		# before this one is removed!
		_player.free()
	
	# restore state
	if dict.has("state"):
		set_game_state(dict.state)
	else:
		set_game_state(Enums.GameState.Pregame)
	
	_pendingGameMode = ZqfUtils.safe_dict_i(dict, "mode", _pendingGameMode)
	_apply_pending_mode()
	# restore environment
	if dict.has("env"):
		game_set_environment(dict.env)
	
	# refresh in-game UI stuff
	var grp:String = HudObjectives.GROUP_NAME
	var fn:String = HudObjectives.FN_CLEAR_OBJECTIVES
	get_tree().call_group(grp, fn)
	_refresh_overlay()
	
	if dict.has("ents"):
		Ents.load_save_dict(dict.ents)
	if dict.has("ai"):
		AI.load_save_dict(dict.ai)
	if dict.has("events"):
		_events.restore(dict.events)
	else:
		_events.clear()
	if Main.is_in_editor():
		EntityEditor.zee_on_restored_entities()

func save_game(filePath:String) -> void:
	print("Writing save " + filePath)
	var data:Dictionary = {
		mapName = Main.get_current_map_name(),
		# we need to know what the former entity file was if we need to reset
		# the level
		entsFileName = Main.get_current_entities_file(),
		mode = _gameMode,
		state = _state,
		env = _environment
	}
	data.ai = AI.write_save_dict()
	data.ents = Ents.write_save_dict()
	data.events = _events.write_state()
	_write_save_file(filePath, data)

func _write_save_file(filePath:String, data:Dictionary) -> void:
	# write file
	var file = File.new()
	file.open(filePath, File.WRITE)
	file.store_string(to_json(data))
	file.close()

###############
# game state
###############
#func begin_game() -> void:
#	print("Game - begin play")
#	set_game_state(Enums.GameState.Playing)
#	var def = _entRoot.get_prefab_def(Entities.PREFAB_PLAYER)
#	var player = def.prefab.instance()
#	get_dynamic_parent().add_child(player)
#	player.teleport(_playerOrigin)

func spawn_player(t:Transform) -> void:
	if _player != null:
		print(">> Cannot spawn player twice! <<")
		return
	var def = Ents.get_prefab_def("player")
	var player = def.prefab.instance()
	get_dynamic_parent().add_child(player)
	player.spawn(t)

func _clear_dynamic_entities() -> void:
	var l:int = get_dynamic_parent().get_child_count()
	print("Game - freeing " + str(l) + " ents from root")
	for _i in range(0, l):
		get_dynamic_parent().get_child(_i).queue_free()

func _set_to_pregame() -> void:
	set_game_state(Enums.GameState.Pregame)

func reset_game() -> void:
	if _state == Enums.GameState.Pregame:
		return
	_camera.detach()
	_camera.global_transform = Transform.IDENTITY
	_clear_dynamic_entities()
	_set_to_pregame()

func set_game_state(gameState) -> void:
	if _state == gameState:
		return
	_state = gameState
	if _state == Enums.GameState.Pregame:
		_camera.detach()
		_camera.global_transform = Transform.IDENTITY

	_refresh_overlay()

func game_on_player_died(_info:Dictionary) -> void:
	print("Game - saw player died!")
	if _state != Enums.GameState.Playing:
		return
	set_game_state(Enums.GameState.Lost)
	
	var gib = _head_gib_t.instance()
	add_child(gib)
	gib.enable_rotation()
	gib.global_transform = _info.headTransform
	if _info.gib:
		gib.launch_gib(1, 0)
	else:
		gib.drop()
	_camera.detach()
	_camera.attach_to(gib)

func game_on_level_completed() -> void:
	if _state == Enums.GameState.Playing:
		set_game_state(Enums.GameState.Won)

func game_on_map_change() -> void:
	print("GAME - saw map change, just loaded is on ")
	_justLoaded = true
	_environments = ZqfUtils.EMPTY_DICT
	if Main.get_app_state() == Enums.AppState.Game:
		print("GAME - play mode")
		EntityEditor.disable()
	elif Main.get_app_state() == Enums.AppState.Editor:
		print("GAME - edit mode")
		EntityEditor.clear()
		EntityEditor.enable()
	else:
		EntityEditor.disable()
		print("GAME - on_map_change - unknown app state")
	game_set_environment(ZqfUtils.EMPTY_STR)
	# _hasPlayerStart = false
	_clear_dynamic_entities()
	_set_to_pregame()

func game_set_environment(name:String) -> void:
	if name == null || name == ZqfUtils.EMPTY_STR:
		_camera.environment = _defaultEnvironment
		_environment = ZqfUtils.EMPTY_STR
		return
	if _environments.has(name):
		_environment = name
		_camera.environment = _environments[name]

func game_pause() -> void:
	print("Game pause")
	get_tree().paused = true
	# get_dynamic_parent().pause_mode = PAUSE_MODE_STOP
	# get_tree().get_current_scene().pause_mode = PAUSE_MODE_STOP

func game_unpause() -> void:
	print("Game resume")
	get_tree().paused = false
	# get_dynamic_parent().pause_mode = PAUSE_MODE_INHERIT
	# get_tree().get_current_scene().pause_mode = PAUSE_MODE_INHERIT

func set_all_forcefields(on:bool) -> void:
	var grp = Groups.ENTS_GROUP_NAME
	var fn = Groups.ENTS_FN_GLOBAL_COMMAND
	var cmd = Groups.ENTS_CMD_ENABLE_ALL_FORCEFIELDS
	if !on:
		cmd = Groups.ENTS_CMD_DISABLE_ALL_FORCEFIELDS
	get_tree().call_group(grp, fn, cmd)

###############
# registers
###############

func register_dynamic_root(_node:Spatial) -> void:
	if _dynamicRoot == null:
		_dynamicRoot = _node
		_factory.prefab_factory_init(_dynamicRoot, _entRoot)
	pass

func deregister_dynamic_root(_node:Spatial) -> void:
	if _node == _dynamicRoot:
		_dynamicRoot = null
		_factory.prefab_factory_init(null, _entRoot)

func register_player(plyr:Player) -> void:
	if _player != null:
		print("Cannot register another player!")
		return
	set_game_state(Enums.GameState.Playing)
	print("Game - register player")
	_player = plyr
	_camera.attach_to(_player.get_node("camera_mount"))
	get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_PLAYER_SPAWNED, _player)

func deregister_player(plyr:Player) -> void:
	if plyr != _player:
		print("Cannot deregister invalid player!")
		return
	print("Game - deregister player")
	_player = null

func register_player_start(_obj:Spatial) -> void:
	_playerOrigin = _obj.global_transform
	_hasPlayerStart = true
	_refresh_overlay()

func deregister_player_start(_obj:Spatial) -> void:
	_hasPlayerStart = false
	_refresh_overlay()

func register_environment(env:Environment, name:String) -> void:
	_environments[name] = env
