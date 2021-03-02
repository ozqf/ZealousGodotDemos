extends Spatial
class_name GameController

var _player_t = preload("res://prefabs/player.tscn")

onready var _entRoot:Spatial = $dynamic

enum GameState { Pregame, Playing, Won, Lost }

var _state = GameState.Pregame

var _playerOrigin:Transform = Transform.IDENTITY

# live player
var _player:Player = null;

func _ready() -> void:
	print("Game singleton init")
	add_to_group("console")

func _process(_delta:float) -> void:
	if _state == GameState.Pregame:
		if Input.is_action_just_pressed("ui_select"):
			begin_game()

func console_on_exec(txt:String) -> void:
	if txt == "reset":
		print("Game - reset")
		reset_game()

###############
# game state
###############
func begin_game() -> void:
	_state = GameState.Playing
	$game_state_overlay/pregame.visible = false
	var player = _player_t.instance()
	_entRoot.add_child(player)
	player.global_transform = _playerOrigin

func reset_game() -> void:
	if _state == GameState.Pregame:
		return
	var l:int = _entRoot.get_child_count()
	for _i in range(0, l):
		_entRoot.get_child(_i).queue_free()
	_state = GameState.Pregame
	$game_state_overlay/pregame.visible = true

###############
# registers
###############

func register_player(plyr:Player) -> void:
	if _player != null:
		print("Cannot register another player!")
		return
	print("Game - register player")
	_player = plyr

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
