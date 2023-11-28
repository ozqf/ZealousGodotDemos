extends Node3D
class_name ZqfMain

const GROUP_NAME_ZQF_GLOBAL:String = "zqf_global"

const GROUP_NAME_ACTOR_PROXIES:String = "actor_proxies"

@onready var _dynamicRoot:Node3D = $dynamic_root
@onready var _worldRoot:Node3D = $world_root

var _playerInputOn:bool = false

func _ready():
	set_player_input_on(false)

###################################################################
# Actor/World node controls
###################################################################

func pause_world() -> void:
	#_dynamicRoot.
	pass

func resume_world() -> void:
	pass

func set_player_input_on(flag:bool) -> void:
	_playerInputOn = flag
	if _playerInputOn:
		remove_mouse_claim(self)
	else:
		add_mouse_claim(self)

func get_player_input_on() -> bool:
	return _playerInputOn

func get_actor_root() -> Node3D:
	return _dynamicRoot

func get_world_root() -> Node3D:
	return _worldRoot




###################################################################
# Mouse claims
###################################################################
var _mouseClaims:Array = []

func _refresh_mouse_claims() -> void:
	if _mouseClaims.size() > 0:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func has_mouse_claims() -> bool:
	return _mouseClaims.size() > 0

func add_mouse_claim(claimant:Node) -> void:
	var i:int = _mouseClaims.find(claimant)
	if i == -1:
		_mouseClaims.push_back(claimant)
	_refresh_mouse_claims()

func remove_mouse_claim(claimant:Node) -> void:
	var i:int = _mouseClaims.find(claimant)
	if i >= 0:
		_mouseClaims.remove_at(i)
	_refresh_mouse_claims()
