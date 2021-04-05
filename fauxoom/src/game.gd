extends Spatial
class_name GameController

const MOUSE_CLAIM:String = "gameUI"

var _player_t = preload("res://prefabs/player.tscn")
var _gib_t = preload("res://prefabs/gib.tscn")

var _entRoot:Entities = null
onready var _pregameUI:Control = $game_state_overlay/pregame
onready var _completeUI:Control = $game_state_overlay/complete
onready var _deathUI:Control = $game_state_overlay/death
onready var _camera:AttachableCamera = $attachable_camera

enum GameState { Pregame, Playing, Won, Lost }

var _state = GameState.Pregame

var _playerOrigin:Transform = Transform.IDENTITY

var _nextDynamicId:int = 1
var _nextStaticId:int = -1

# live player
var _player:Player = null;

var _emptyTargetInfo:Dictionary = {
	id = 0,
	position = Vector3(),
	yawDegrees = 0
}

func _ready() -> void:
	print("Game singleton init")
	_entRoot = Ents
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	add_to_group(Groups.GAME_GROUP_NAME)
	_refresh_overlay()
	var _result = $game_state_overlay/death/menu/reset.connect("pressed", self, "on_clicked_reset")
	_result = $game_state_overlay/complete/menu/reset.connect("pressed", self, "on_clicked_reset")
	Main.set_camera(_camera)

func _process(_delta:float) -> void:
	pass
	# if _state == GameState.Pregame:
	# 	if Input.is_action_just_pressed("ui_select"):
	# 		begin_game()

func get_entity_prefab(name:String) -> Object:
	return _entRoot.get_prefab_def(name).prefab

# disable of menu HAS to be triggered from here in web mode
func _input(_event) -> void:
	if _event is InputEventKey:
		if _state == GameState.Pregame && Input.is_action_just_pressed("ui_select"):
			begin_game()

func get_dynamic_parent() -> Spatial:
	return self

func on_clicked_reset() -> void:
	get_tree().call_group("console", "console_on_exec", "reset", ["reset"])

func console_on_exec(txt:String, _tokens:PoolStringArray) -> void:
	if txt == "reset":
		print("Game - reset")
		reset_game()

func _refresh_overlay() -> void:
	if _state == GameState.Pregame:
		_pregameUI.visible = true
		_completeUI.visible = false
		_deathUI.visible = false
		MouseLock.add_claim(get_tree(), MOUSE_CLAIM)
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

###############
# game state
###############
func begin_game() -> void:
	_state = GameState.Playing
	_refresh_overlay()
	var def = _entRoot.get_prefab_def(Entities.PREFAB_PLAYER)
	var player = def.prefab.instance()
	_entRoot.add_child(player)
	player.teleport(_playerOrigin)
	get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_PLAYER_SPAWNED, player)

func _clear_dynamic_entities() -> void:
	var l:int = _entRoot.get_child_count()
	print("Game - freeing " + str(l) + " ents from root")
	for _i in range(0, l):
		_entRoot.get_child(_i).queue_free()

func _set_to_pregame() -> void:
	_state = GameState.Pregame
	_refresh_overlay()

func reset_game() -> void:
	if _state == GameState.Pregame:
		return
	_camera.detach()
	_camera.global_transform = Transform.IDENTITY
	get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_RESET)
	_clear_dynamic_entities()
	_set_to_pregame()

func game_on_player_died(_info:Dictionary) -> void:
	print("Game - saw player died!")
	if _state != GameState.Playing:
		return
	_state = GameState.Lost
	_refresh_overlay()
	
	var def = _entRoot.get_prefab_def(Entities.PREFAB_GIB)
	var gib = def.prefab.instance()
	add_child(gib)
	gib.global_transform = _info.headTransform
	if _info.gib:
		gib.launch(1, 0)
	else:
		gib.drop()
	_camera.detach()
	_camera.attach_to(gib)

func game_on_level_completed() -> void:
	if _state == GameState.Playing:
		_state = GameState.Won
		_refresh_overlay()

func game_on_map_change() -> void:
	_clear_dynamic_entities()
	_set_to_pregame()

###############
# registers
###############

func assign_dynamic_id() -> int:
	var id:int = _nextDynamicId
	_nextDynamicId += 1
	return id

func assign_static_id() -> int:
	var id:int = _nextStaticId
	_nextStaticId -= 1
	return id

func register_player(plyr:Player) -> void:
	if _player != null:
		print("Cannot register another player!")
		return
	print("Game - register player")
	_player = plyr
	_camera.attach_to(_player.get_node("camera_mount"))

func deregister_player(plyr:Player) -> void:
	if plyr != _player:
		print("Cannot deregister invalid player!")
		return
	print("Game - deregister player")
	_player = null

func register_player_start(_obj:Spatial) -> void:
	_playerOrigin = _obj.global_transform

func deregister_player_start(_obj:Spatial) -> void:
	pass

###############
# AI
###############

func check_los_to_player(origin:Vector3) -> bool:
	if !_player:
		return false
	var dest = _player.get_targetting_info().position
	return ZqfUtils.los_check(_entRoot, origin, dest, 1)

func mob_check_target_old(_current:Spatial) -> Spatial:
	if !_player:
		return null
	return _player as Spatial

func mob_check_target(_current:Dictionary) -> Dictionary:
	if !_player:
		return _emptyTargetInfo
	return _player.get_targetting_info()

func get_player_target() -> Dictionary:
	if !_player:
		return _emptyTargetInfo
	return _player.get_targetting_info()
