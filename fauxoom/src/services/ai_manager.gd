extends Spatial

var _entRoot:Entities = null

# live player
var _player:Player = null

# cheats
var _noTarget:bool = false

var _emptyTargetInfo:Dictionary = {
	id = 0,
	position = Vector3(),
	yawDegrees = 0
}

# Called when the node enters the scene tree for the first time.
func _ready():
	print("AI singleton init")
	_entRoot = Ents

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
