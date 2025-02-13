extends Node3D
class_name ZqfMain

const GROUP_APP:String = "app"
const FN_ON_APP_EVENT:String = "on_app_event"
const GROUP_NAME_ACTOR_PROXIES:String = "actor_proxies"

const APP_EVENT_PLAY:String = "play"
const APP_EVENT_PAUSE:String = "pause"

@onready var _dynamicRoot:Node3D = $dynamic_root
@onready var _worldRoot:Node3D = $world_root

var _playerInputOn:bool = false
var _mouseClaims:Array = []
var _pauseClaims:Array = []

func get_player_input_on() -> bool:
	return _playerInputOn

###################################################################
# Scene Control
###################################################################

func get_actor_root() -> Node3D:
	return _dynamicRoot

func clear_all_actors() -> void:
	for actor in _dynamicRoot.get_children():
		actor.free()

func create_actor(type:PackedScene) -> Node3D:
	var actor:Node3D = type.instantiate() as Node3D
	_dynamicRoot.add_child(actor)
	return actor

func create_new_world(worldScene:PackedScene) -> Node3D:
	for child in _worldRoot.get_children():
		child.free()
	var world:Node3D = worldScene.instantiate() as Node3D
	_worldRoot.add_child(world)
	return world

###################################################################
# Mouse claims
###################################################################

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

###################################################################
# Pause claims
###################################################################

func has_pause_claims() -> bool:
	return _pauseClaims.size() > 0

func add_pause_claim(claimant:Node) -> void:
	var prevCount:int = _pauseClaims.size()
	var i:int = _pauseClaims.find(claimant)
	if i == -1:
		_pauseClaims.push_back(claimant)
	if prevCount == 0:
		self.get_tree().call_group(GROUP_APP, FN_ON_APP_EVENT, APP_EVENT_PAUSE)

func remove_pause_claim(claimant:Node) -> void:
	var i:int = _pauseClaims.find(claimant)
	if i >= 0:
		_pauseClaims.remove_at(i)
		if _pauseClaims.is_empty():
			self.get_tree().call_group(GROUP_APP, FN_ON_APP_EVENT, APP_EVENT_PLAY)
