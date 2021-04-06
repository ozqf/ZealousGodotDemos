extends KinematicBody
class_name Player

onready var _ent:Entity = $Entity
onready var _head:Spatial = $head
onready var _cameraMount:Spatial = $camera_mount
onready var _motor:ZqfFPSMotor = $motor
onready var _attack:PlayerAttack = $attack
onready var _inventory:Inventory = $inventory
onready var _hud:Hud = $hud
onready var _interactor:PlayerObjectInteractor = $head/interaction_ray_cast

var _inputOn:bool = false

var _gameplayInputOn:bool = true
var _appInputOn:bool = true

var _dead:bool = false
var _health:int = 100
var _swayTime:float = 0.0

var _targettingInfo:Dictionary = {
	id = 1,
	position = Vector3(),
	forward = Vector3(),
	yawDegrees = 0
}

var _status:Dictionary = {
	health = 100,
	yawDegrees = 0,
	bullets = 50,
	shells = 0
}

func _ready():
	# Main.set_camera(_head)
	
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	
	_motor.init_motor(self, _head)
	_motor.set_input_enabled(false)
	_attack.init_attack(_head, self, _inventory)
	_attack.set_attack_enabled(false)
	
	var _result = _attack.connect("fire_ssg", _hud, "on_shoot_ssg")
	_result = _attack.connect("change_weapon", _hud, "on_change_weapon")
	_result = connect("tree_exiting", self, "_on_tree_exiting")
	_result = _ent.connect("entity_append_state", self, "append_state")
	_result = _ent.connect("entity_restore_state", self, "restore_state")

	Game.register_player(self)

func append_state(_dict:Dictionary) -> void:
	var t:Transform = Transform.IDENTITY
	t.origin = self.global_transform.origin
	t.basis = _head.global_transform.basis
	_dict.xform = ZqfUtils.transform_to_dict(t)

func restore_state(_dict:Dictionary) -> void:
	var t:Transform = ZqfUtils.transform_from_dict(_dict.xform)
	teleport(t)

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
	_appInputOn = Main.get_input_on()
	_motor.set_input_enabled(_gameplayInputOn && _appInputOn)
	_attack.set_attack_enabled(_gameplayInputOn && _appInputOn)

func _process(_delta):
	_refresh_input_on()
	if _appInputOn && _gameplayInputOn && Input.is_action_just_pressed("interact"):
		_interactor.use_target()
	
	var t:Transform = _head.transform
	var swayScale:float = _motor.get_sway_scale()
	_swayTime += (_delta * (swayScale * 12))
	# if _motor.get_velocity().length() > 0:
	#	_swayTime += (_delta * 12)
	t.origin.y += sin(_swayTime) * 0.025
	_cameraMount.transform = t
	
	_targettingInfo.position = _head.global_transform.origin
	_targettingInfo.yawDegrees = _motor.m_yaw
	_targettingInfo.forward = ZqfUtils.yaw_to_flat_vector3(_motor.m_yaw)
	var txt = ""
	txt = "real forward: " + str(-_head.global_transform.basis.z) + "\n"
	txt += "pos: " + str(global_transform.origin) + "\n"
	txt += "yaw: " + str(_motor.m_yaw) + "\n"
	Main.playerDebug = txt
	
	# update status info for UI
	_status.bullets = _inventory.get_count("bullets")
	_status.shells = _inventory.get_count("shells")
	_status.yawDegrees = _motor.m_yaw
	_status.health = _health
	_status.swayScale = swayScale
	_status.swayTime = _swayTime
	_status.hasInteractionTarget = _interactor.get_is_colliding()
	
	var grp = Groups.PLAYER_GROUP_NAME
	var fn = Groups.PLAYER_FN_STATUS
	get_tree().call_group(grp, fn, _status)

# returns amount taken
func give_item(itemType:String, amount:int) -> int:
	var took:int = _inventory.give_item(itemType, amount)
	#if took > 0:
	#	print("Player took " + itemType + " x " + str(took))
	#	print(_inventory.debug())
	return took

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
	info.gib = false
	get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_PLAYER_DIED, info)
	queue_free()
