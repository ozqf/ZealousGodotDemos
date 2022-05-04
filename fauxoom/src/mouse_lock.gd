extends Node
class_name MouseLock

const GROUP_NAME:String = "mouse_lock"
const ADD_LOCK_FN:String = "on_add_mouse_claim"
const REMOVE_LOCK_FN:String = "on_remove_mouse_claim"
const DEBUG_LOCK_FN:String = "on_debug_mouse_claims"

# all claims should be unique!
var _claims:PoolStringArray = []

static func add_claim(t:SceneTree, claim:String) -> void:
	t.call_group(GROUP_NAME, ADD_LOCK_FN, claim)

static func remove_claim(t:SceneTree, claim:String) -> void:
	t.call_group(GROUP_NAME, REMOVE_LOCK_FN, claim)

func _index_of(txt:String) -> int:
	for i in range(0, _claims.size()):
		if _claims[i] == txt:
			return i
	return -1

func _ready() -> void:
	add_to_group(GROUP_NAME)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _refresh_mouse_lock() -> void:
	var c:int = _claims.size()
	if c > 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func on_debug_mouse_claims() -> void:
	var txt:String = "Claims: "
	for _i in range(0, _claims.size()):
		txt += _claims[_i] + ", "
	print(txt)

func on_add_mouse_claim(claim:String) -> void:
	if _index_of(claim) >= 0:
		return
	_claims.push_back(claim)
	_refresh_mouse_lock()

func on_remove_mouse_claim(claim:String) -> void:
	var i:int = _index_of(claim)
	if i != -1:
		_claims.remove(i)
	_refresh_mouse_lock()
