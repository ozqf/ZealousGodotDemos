extends Spatial
class_name GameController

const MOUSE_CLAIM:String = "gameUI"

const START_SAVE_FILE_NAME:String = "start"
const CHECKPOINT_SAVE_FILE_NAME:String = "checkpoint"
const QUICK_SAVE_FILE_NAME:String = "quick"

var _player_t = preload("res://prefabs/player.tscn")
var _gib_t = preload("res://prefabs/gib.tscn")
var _hitInfo_type = preload("res://src/defs/hit_info.gd")

var _entRoot:Entities = null
onready var _pregameUI:Control = $game_state_overlay/pregame
onready var _completeUI:Control = $game_state_overlay/complete
onready var _deathUI:Control = $game_state_overlay/death
onready var _hintLabelTop:Label = $game_state_overlay/hint_text/hint_label_top

onready var _camera:AttachableCamera = $attachable_camera

enum GameState { Pregame, Playing, Won, Lost }

var _state = GameState.Pregame

var _hasPlayerStart:bool = false
var _playerOrigin:Transform = Transform.IDENTITY

# cheats
var _noTarget:bool = false

# live player
var _player:Player = null
var _pendingSaveName:String = ""
var _pendingLoadDict:Dictionary = {}
# this must default to true so that it triggers on initial startup
var _justLoaded:bool = true

var _hintTextTick:float = 0

var _emptyTargetInfo:Dictionary = {
	id = 0,
	position = Vector3(),
	yawDegrees = 0
}

func _ready() -> void:
	print("Game singleton init")
	_entRoot = Ents
	add_to_group(Config.GROUP)
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	add_to_group(Groups.GAME_GROUP_NAME)
	_refresh_overlay()
	var _result = $game_state_overlay/death/menu/reset.connect("pressed", self, "on_clicked_reset")
	_result = $game_state_overlay/complete/menu/reset.connect("pressed", self, "on_clicked_reset")
	Main.set_camera(_camera)
	_hintLabelTop.visible = false

	# does checkpoint exist?
	if ZqfUtils.does_file_exist(CHECKPOINT_SAVE_FILE_NAME):
		print("Checkpoint file found")
	else:
		print("No checkpoint file found")

func new_hit_info() -> HitInfo:
	return _hitInfo_type.new()

func config_changed(_cfg:Dictionary) -> void:
	_camera.fov = Config.cfg.r_fov

func write_save_file(fileName:String) -> void:
	var path = build_save_path(fileName)
	save_game(path)

func show_hint_text(txt:String) -> void:
	print("Show hint text")
	_hintTextTick = 3
	_hintLabelTop.text = txt
	_hintLabelTop.visible = true

func _process(_delta:float) -> void:
	if get_tree().paused == false:
		if _hintTextTick <= 0:
			_hintLabelTop.visible = false
		else:
			_hintTextTick -= _delta
	if _state == GameState.Pregame && _hasPlayerStart:
		begin_game()
	if _pendingSaveName != "":
		# if we are writing a map start save, write the checkpoint too!
		if _pendingSaveName == START_SAVE_FILE_NAME:
			write_save_file(CHECKPOINT_SAVE_FILE_NAME)
		write_save_file(_pendingSaveName)
		_pendingSaveName = ""
	if _pendingLoadDict:
		print("Have pending ents - loading")
		# we may have just switched maps but have entities to load.
		# make sure to not trigger the initial spawns events
		_justLoaded = false
		# clear pending and run
		var dict = _pendingLoadDict
		_pendingLoadDict = {}
		load_entity_dict(dict)
	elif _justLoaded:
		_justLoaded = false
		print("Just loaded fresh map - writing reset save")
		# tell initial spawns to run
		get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_RUN_MAP_SPAWNS)
		# write restart savegame
		_pendingSaveName = START_SAVE_FILE_NAME
	# if _state == GameState.Pregame:
	# 	if Input.is_action_just_pressed("ui_select"):
	# 		begin_game()

func build_save_path(fileName) -> String:
	return "user://" + fileName + ".json"

func get_entity_prefab(name:String) -> Object:
	return _entRoot.get_prefab_def(name).prefab

# disable of menu HAS to be triggered from here in web mode
func _input(_event) -> void:
	if _event is InputEventKey:
		if !Main.get_input_on():
			# menu is up, abort
			return
		if _state == GameState.Pregame:
			if !_hasPlayerStart:
				Main.set_input_off()
				return
			elif Input.is_action_just_pressed("ui_select"):
				begin_game()
		# var a = _state == GameState.Pregame
		# var b = Input.is_action_just_pressed("ui_select")
		# var c = Main.get_input_on()
		# var d = _hasPlayerStart
		# if a && b && c && d:
		# 	begin_game()

func get_dynamic_parent() -> Spatial:
	return _entRoot

func on_restart_map() -> void:
	get_tree().call_group("console", "console_on_exec", "load start", ["load", "start"])

func on_clicked_retry() -> void:
	get_tree().call_group("console", "console_on_exec", "load checkpoint", ["load", "checkpoint"])

func on_clicked_reset() -> void:
	get_tree().call_group("console", "console_on_exec", "load checkpoint", ["load", "start"])

func _refresh_overlay() -> void:
	if _state == GameState.Pregame:
		_pregameUI.visible = true
		_completeUI.visible = false
		_deathUI.visible = false
		# MouseLock.add_claim(get_tree(), MOUSE_CLAIM)
		MouseLock.remove_claim(get_tree(), MOUSE_CLAIM)
	elif _state == GameState.Won:
		_pregameUI.visible = false
		_completeUI.visible = true
		_deathUI.visible = false
		MouseLock.add_claim(get_tree(), MOUSE_CLAIM)
	elif _state == GameState.Lost:
		_pregameUI.visible = false
		_completeUI.visible = false
		_deathUI.visible = true
		MouseLock.add_claim(get_tree(), MOUSE_CLAIM)
	else:
		_pregameUI.visible = false
		_completeUI.visible = false
		_deathUI.visible = false
		MouseLock.remove_claim(get_tree(), MOUSE_CLAIM)

func console_on_exec(txt:String, _tokens:PoolStringArray) -> void:
	var numTokens:int = _tokens.size()
	if txt == "reset":
		print("Game - reset")
		reset_game()
	elif txt == "notarget":
		_noTarget = !_noTarget
		print("No Target: " + str(_noTarget))
	elif txt == "current_map":
		print("Playing map " + get_tree().get_current_scene().filename)
	elif _tokens[0] == "save":
		var fileName:String = QUICK_SAVE_FILE_NAME
		if numTokens >= 2:
			fileName = _tokens[1]
		_pendingSaveName = fileName
	elif _tokens[0] == "load":
		var fileName:String = QUICK_SAVE_FILE_NAME
		if numTokens >= 2:
			fileName = _tokens[1]
		var path:String = build_save_path(fileName)
		var data:Dictionary = ZqfUtils.load_dict_json_file(path)
		if !data:
			return
		_pendingLoadDict = data
		print("Set pending ents dict from " + path)
		var curScene = get_tree().get_current_scene().filename
		var newScene = data.mapPath
		if curScene != newScene:
			print("Save is for a different map...")
			Main.change_map(data.mapPath)
			# get_tree().change_scene(data.mapPath)
		else:
			print("Save is same map - no change")

###############
# save/load state
###############
func load_entity_dict(dict:Dictionary) -> void:
	if _player:
		# have to free immediately or new player will be spawned
		# before this one is removed!
		_player.free()
	
	set_game_state(dict.state)
	_refresh_overlay()
	Ents.load_save_dict(dict.ents)

func save_game(filePath:String) -> void:
	print("Writing save " + filePath)
	var data:Dictionary = {
		mapPath = get_tree().get_current_scene().filename,
		state = _state
	}
	data.ents = Ents.write_save_dict()
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
func begin_game() -> void:
	set_game_state(GameState.Playing)
	var def = _entRoot.get_prefab_def(Entities.PREFAB_PLAYER)
	var player = def.prefab.instance()
	_entRoot.add_child(player)
	player.teleport(_playerOrigin)

func _clear_dynamic_entities() -> void:
	var l:int = _entRoot.get_child_count()
	print("Game - freeing " + str(l) + " ents from root")
	for _i in range(0, l):
		_entRoot.get_child(_i).queue_free()

func _set_to_pregame() -> void:
	set_game_state(GameState.Pregame)

func reset_game() -> void:
	if _state == GameState.Pregame:
		return
	_camera.detach()
	_camera.global_transform = Transform.IDENTITY
	_clear_dynamic_entities()
	_set_to_pregame()

func set_game_state(gameState) -> void:
	if _state == gameState:
		return
	_state = gameState
	if _state == GameState.Pregame:
		_camera.detach()
		_camera.global_transform = Transform.IDENTITY
	_refresh_overlay()

func game_on_player_died(_info:Dictionary) -> void:
	print("Game - saw player died!")
	if _state != GameState.Playing:
		return
	set_game_state(GameState.Lost)
	
	var def = _entRoot.get_prefab_def(Entities.PREFAB_GIB)
	var gib = def.prefab.instance()
	add_child(gib)
	gib.global_transform = _info.headTransform
	if _info.gib:
		gib.launch_gib(1, 0)
	else:
		gib.drop()
	_camera.detach()
	_camera.attach_to(gib)

func game_on_level_completed() -> void:
	if _state == GameState.Playing:
		set_game_state(GameState.Won)

func game_on_map_change() -> void:
	print("Game - saw map change")
	_justLoaded = true
	# _hasPlayerStart = false
	_clear_dynamic_entities()
	_set_to_pregame()

func game_pause() -> void:
	print("Game pause")
	get_tree().paused = true
	# _entRoot.pause_mode = PAUSE_MODE_STOP
	# get_tree().get_current_scene().pause_mode = PAUSE_MODE_STOP

func game_unpause() -> void:
	print("Game resume")
	get_tree().paused = false
	# _entRoot.pause_mode = PAUSE_MODE_INHERIT
	# get_tree().get_current_scene().pause_mode = PAUSE_MODE_INHERIT

###############
# registers
###############

func register_player(plyr:Player) -> void:
	if _player != null:
		print("Cannot register another player!")
		return
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

###############
# AI
###############

# returns last gib spawned
func spawn_gibs(origin:Vector3, dir:Vector3, count:int) -> Spatial:
	var def = _entRoot.get_prefab_def(Entities.PREFAB_GIB)
	var result = null;
	for _i in range(0, count):
		var gib = def.prefab.instance()
		result = gib
		add_child(gib)
		var pos:Vector3 = origin
		pos.x += rand_range(-0.5, 0.5)
		pos.y += rand_range(0, 1.5)
		pos.z += rand_range(-0.5, 0.5)
		gib.global_transform.origin = pos
		gib.launch_gib(dir, 1, 0)
	return result

func check_los_to_player(origin:Vector3) -> bool:
	if !_player:
		return false
	var dest = _player.get_targetting_info().position
	return ZqfUtils.los_check(_entRoot, origin, dest, 1)

func check_player_in_front(origin:Vector3, yawDegrees:float) -> bool:
	if !_player:
		return false
	var dest = _player.get_targetting_info().position
	var yawToPlayer:float = rad2deg(ZqfUtils.yaw_between(dest, origin))
	yawDegrees = ZqfUtils.cap_degrees(yawDegrees - 90)
	yawToPlayer = ZqfUtils.cap_degrees(yawToPlayer)
	# var diff1:float = yawToPlayer - yawDegrees
	var diff2:float = yawDegrees - yawToPlayer
	# print("Mob yaw " + str(yawDegrees) + " vs to player angle " + str(yawToPlayer))
	# print("  Diff1: " + str(diff1) + " diff2: " + str(diff2))
	if diff2 >= 0 && diff2 <= 180:
		return true
	return false

func mob_check_target_old(_current:Spatial) -> Spatial:
	if !_player:
		return null
	return _player as Spatial

func mob_check_target(_current:Dictionary) -> Dictionary:
	if !_player || _noTarget:
		return _emptyTargetInfo
	return _player.get_targetting_info()

func get_player_target() -> Dictionary:
	if !_player || _noTarget:
		return _emptyTargetInfo
	return _player.get_targetting_info()
