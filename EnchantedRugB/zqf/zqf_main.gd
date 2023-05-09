extends Node
class_name ZqfMain

var _playerInputOn:bool = false

func _ready():
	set_player_input_on(false)

func _process(_delta):
	if Input.is_action_just_pressed("toggle_console"):
		set_player_input_on(!_playerInputOn)
	pass

func set_player_input_on(flag:bool) -> void:
	_playerInputOn = flag
	if _playerInputOn:
		remove_mouse_claim(self)
	else:
		add_mouse_claim(self)
#	if _playerInputOn:
#		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
#	else:
#		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func get_player_input_on() -> bool:
	return _playerInputOn

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

func add_mouse_claim(owner:Node) -> void:
	var i:int = _mouseClaims.find(owner)
	if i == -1:
		_mouseClaims.push_back(owner)
	_refresh_mouse_claims()

func remove_mouse_claim(owner:Node) -> void:
	var i:int = _mouseClaims.find(owner)
	if i >= 0:
		_mouseClaims.remove_at(i)
	_refresh_mouse_claims()
