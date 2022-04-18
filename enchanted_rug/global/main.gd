extends Spatial

var _prj_info_t = preload("res://src/defs/prj_launch_info.gd")

const GROUP_NAME:String = "game"

const GAME_TRIGGER_FN:String = "game_trigger"
const GAME_PLAYER_ADD_FN:String = "game_player_add"
const GAME_PLAYER_REMOVE_FN:String = "game_player_remove"

var _player = null

var _emptyTargetInfo:Dictionary = {
	"valid": false,
	"position": Vector3(),
	"velocity": Vector3(),
	"forward": Vector3()
}

func _ready() -> void:
	add_to_group(Console.GROUP)
	add_to_group(GROUP_NAME)

func new_prj_info() -> PrjLaunchInfo:
	return _prj_info_t.new()

func console_execute(_txt:String, _tokens) -> void:
	if _txt == "reset":
		get_tree().call_group(GROUP_NAME, "game_reset")
	elif _tokens[0] == "trigger" && _tokens.size() >= 2:
		print("Triggering actors: " + str(_tokens[1]))
		get_tree().call_group(GROUP_NAME, GAME_TRIGGER_FN, _tokens[1])

func game_player_add(_obj) -> void:
	print("Main - spawn player spawn")
	_player = _obj

func game_player_remove(_obj) -> void:
	print("Main - spawn player despawn")
	_player = null

func get_target() -> Dictionary:
	if _player == null:
		return _emptyTargetInfo
	return _player.get_target_info()
