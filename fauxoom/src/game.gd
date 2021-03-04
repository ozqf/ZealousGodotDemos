extends Spatial
class_name GameController

const MOUSE_CLAIM:String = "gameUI"

var _player_t = preload("res://prefabs/player.tscn")
var _gib_t = preload("res://prefabs/gib.tscn")

onready var _entRoot:Spatial = $dynamic
onready var _pregameUI:Control = $game_state_overlay/pregame
onready var _completeUI:Control = $game_state_overlay/complete
onready var _deathUI:Control = $game_state_overlay/death
onready var _camera:AttachableCamera = $attachable_camera

enum GameState { Pregame, Playing, Won, Lost }

var _state = GameState.Pregame

var _playerOrigin:Transform = Transform.IDENTITY

# live player
var _player:Player = null;

func _ready() -> void:
	print("Game singleton init")
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	add_to_group(Groups.GAME_GROUP_NAME)
	_refresh_overlay()
	Main.set_camera(_camera)

func _process(_delta:float) -> void:
	pass
	# if _state == GameState.Pregame:
	# 	if Input.is_action_just_pressed("ui_select"):
	# 		begin_game()

# disable of menu HAS to be triggered from here in web mode
func _input(_event) -> void:
	if _event is InputEventKey:
		if _state == GameState.Pregame && Input.is_action_just_pressed("ui_select"):
			begin_game()

func game_on_player_died(_info:Dictionary) -> void:
	print("Game - saw player died!")
	if _state != GameState.Playing:
		return
	_state = GameState.Lost
	_refresh_overlay()

	var gib = _gib_t.instance()
	add_child(gib)
	gib.global_transform = _info.headTransform
	_camera.detach()
	_camera.attach_to(gib)

func game_on_level_completed() -> void:
	if _state == GameState.Playing:
		_state = GameState.Won
		_refresh_overlay()

func console_on_exec(txt:String) -> void:
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
	var player = _player_t.instance()
	_entRoot.add_child(player)
	player.global_transform = _playerOrigin

func reset_game() -> void:
	if _state == GameState.Pregame:
		return
	var l:int = _entRoot.get_child_count()
	_camera.detach()
	_camera.global_transform = Transform.IDENTITY
	get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_RESET)
	print("Game - freeing " + str(l) + " ents from root")
	for _i in range(0, l):
		_entRoot.get_child(_i).queue_free()
	_state = GameState.Pregame
	_refresh_overlay()

###############
# registers
###############

func register_player(plyr:Player) -> void:
	if _player != null:
		print("Cannot register another player!")
		return
	print("Game - register player")
	_player = plyr
	_camera.attach_to(_player.get_node("head"))

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

func mob_check_target(_current:Spatial) -> Spatial:
	if !_player:
		return null
	return _player as Spatial
