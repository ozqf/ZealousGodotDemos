extends KinematicBody
class_name Player

onready var _head:Spatial = $head
onready var _motor:FPSMotor = $motor
onready var _attack:PlayerAttack = $attack
onready var _hud:Hud = $hud

var _inputOn:bool = false

var _gameplayInputOn:bool = true
var _appInputOn:bool = true

var _dead:bool = false
var _health:int = 100

var _targettingInfo:Dictionary = {
	id = 1,
	position = Vector3(),
	forward = Vector3(),
	yawDegrees = 0
}

func _ready():
	# Main.set_camera(_head)
	
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	
	_motor.init_motor(self, _head)
	_motor.set_input_enabled(false)
	_attack.init_attack(_head, self)
	_attack.set_attack_enabled(false)
	
	var _foo = _attack.connect("fire_ssg", _hud, "on_shoot_ssg")
	_foo = _attack.connect("change_weapon", _hud, "on_change_weapon")
	_foo = connect("tree_exiting", self, "_on_tree_exiting")

	Game.register_player(self)

func teleport(_trans:Transform) -> void:
	# copy rotation, clear and pass to motor
	# print("Player teleport transform " + str(_trans))
	var _forward:Vector3 = _trans.basis.z
	var _yaw:float = rad2deg(atan2(_forward.x, _forward.z))
	# print("Player teleport yaw " + str(_yaw))
	# var rot:Basis = _trans.basis
	_trans.basis = Basis.IDENTITY
	self.global_transform = _trans
	_motor.set_yaw_degrees(_yaw)

func get_targetting_info() -> Dictionary:
	return _targettingInfo

func game_on_reset() -> void:
	queue_free()

func game_on_map_change() -> void:
	queue_free()

func _on_tree_exiting() -> void:
	Game.deregister_player(self)
	# Main.clear_camera(_head)

func console_on_exec(_txt:String, _tokens:PoolStringArray) -> void:
	if _txt == "kill":
		kill()

func game_on_level_completed() -> void:
#	print("Player disable input")
#	_gameplayInputOn = false
	queue_free()
	# _motor.set_input_enabled(false)
	# _attack.set_attack_enabled(false)

func _refresh_input_on() -> void:
	var flag:bool = Main.get_input_on()
	_motor.set_input_enabled(_gameplayInputOn && flag)
	_attack.set_attack_enabled(_gameplayInputOn && flag)

func _process(_delta):
	_refresh_input_on()
	_targettingInfo.position = _head.global_transform.origin
	_targettingInfo.yawDegrees = _motor.m_yaw
	_targettingInfo.forward = ZqfUtils.yaw_to_flat_vector3(_motor.m_yaw)
	var txt = ""
	txt = "real forward: " + str(-_head.global_transform.basis.z) + "\n"
	txt += "pos: " + str(global_transform.origin) + "\n"
	txt += "yaw: " + str(_motor.m_yaw) + "\n"
	Main.playerDebug = txt
	
	var grp = Groups.PLAYER_GROUP_NAME
	var fn = Groups.PLAYER_FN_STATUS
	get_tree().call_group(grp, fn, _health, _motor.m_yaw)

func hit(hitInfo) -> int:
	if _dead:
		return 0
	var dmg = hitInfo.damage
	_health -= dmg
	if _health <= 0:
		kill()
		return dmg + _health
	else:
		var grp:String = Groups.PLAYER_GROUP_NAME
		var fn:String = Groups.PLAYER_FN_HIT
		var data:Dictionary = {
			damage = dmg,
			direction = hitInfo.direction,
			selfYawDegrees = _motor.m_yaw
		}
		get_tree().call_group(grp, fn, data)
		return dmg

func kill() -> void:
	if _dead:
		return
	_dead = true
	var info:Dictionary = {}
	info.transform = global_transform
	info.headTransform = _head.global_transform
	get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_PLAYER_DIED, info)
	queue_free()
