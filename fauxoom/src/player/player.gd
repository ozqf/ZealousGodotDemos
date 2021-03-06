extends KinematicBody
class_name Player

const MAX_HEALTH:int = 100

onready var _ent:Entity = $Entity
onready var _head:Spatial = $head
onready var _cameraMount:Spatial = $camera_mount
onready var _motor:ZqfFPSMotor = $motor
onready var _attack:PlayerAttack = $attack
onready var _inventory = $inventory
onready var _hud:Hud = $hud
onready var _interactor:PlayerObjectInteractor = $head/interaction_ray_cast

var _inputOn:bool = false

var _gameplayInputOn:bool = true
var _appInputOn:bool = true

var _startTransform:Transform = Transform.IDENTITY
var _recoverTransform:Transform = Transform.IDENTITY

var _godMode:bool = false
var _dead:bool = false
var _health:int = MAX_HEALTH
var _swayTime:float = 0.0

var _targettingInfo:Dictionary = {
	id = 1,
	position = Vector3(),
	forward = Vector3(),
	flatForward = Vector3(),
	yawDegrees = 0
}

var _status:Dictionary = {
	health = 100,
	energy = 100,
	yawDegrees = 0,
	bullets = 50,
	shells = 0
}

func _ready():
	# Main.set_camera(_head)
	# _targettingInfo.id = Entities.PLAYER_RESERVED_ID
	add_to_group(Config.GROUP)
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	
	_motor.init_motor(self, _head)
	_motor.set_input_enabled(false)
	_inventory.connect("weapon_changed", _hud, "inventory_weapon_changed")
	_inventory.custom_init(_head, self, _hud)
	_attack.init_attack(_interactor, _inventory)
	_attack.set_attack_enabled(false)
	
	var _result
	# _result  = _attack.connect("fire", _hud, "on_player_shoot")
	# _result = _attack.connect("fire", self, "on_player_shoot")
	# _result = _attack.connect("change_weapon", _hud, "on_change_weapon")
	_result = connect("tree_exiting", self, "_on_tree_exiting")
	_result = _ent.connect("entity_append_state", self, "append_state")
	_result = _ent.connect("entity_restore_state", self, "restore_state")

	Game.register_player(self)
	config_changed(Config.cfg)

func on_player_shoot() -> void:
	# _audio.play()
	pass

func append_state(_dict:Dictionary) -> void:
	var t:Transform = Transform.IDENTITY
	t.origin = self.global_transform.origin
	t.basis = _head.global_transform.basis
	_dict.xform = ZqfUtils.transform_to_dict(t)
	_inventory.append_state(_dict)

func restore_state(_dict:Dictionary) -> void:
	var t:Transform = ZqfUtils.transform_from_dict(_dict.xform)
	teleport(t)
	_inventory.restore_state(_dict)

func config_changed(_cfg:Dictionary) -> void:
	_motor.mouseSensitivity = _cfg.i_sensitivity
	_motor.invertedY = _cfg.i_invertedY

func spawn(xform:Transform) -> void:
	_startTransform = xform
	_recoverTransform = xform
	teleport(xform)

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
	if _txt == "resetplayer":
		print("Reset player")
		teleport(_startTransform)
	if _txt == "god":
		_godMode = !_godMode
		print("Godmode: " + str(_godMode))
	if _tokens[0] == "give":
		if _tokens.size() == 2 && _tokens[1] == "all":
			give_all()
		if _tokens.size() == 3:
			var count = int(_tokens[2])
			_inventory.give_item(_tokens[1], count)
	if _txt == "inventory":
		_inventory.debug()

func give_all() -> void:
	_inventory.give_all()

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
	# if _appInputOn && _gameplayInputOn && Input.is_action_just_pressed("interact"):
	# 	_interactor.use_target()
	
	var t:Transform = _head.transform
	var swayScale:float = _motor.get_sway_scale()
	_swayTime += (_delta * (swayScale * 12))
	# if _motor.get_velocity().length() > 0:
	#	_swayTime += (_delta * 12)
	t.origin.y += sin(_swayTime) * 0.025
	_cameraMount.transform = t
	
	_targettingInfo.position = _head.global_transform.origin
	_targettingInfo.yawDegrees = _motor.m_yaw
	_targettingInfo.forward = -_head.global_transform.basis.z
	_targettingInfo.flatForward = ZqfUtils.yaw_to_flat_vector3(_motor.m_yaw)
	_targettingInfo.velocity = _motor.get_velocity()

	var txt = ""
	txt = "real forward: " + str(_targettingInfo.forward) + "\n"
	txt += "pos: " + str(_targettingInfo.position) + "\n"
	txt += "yaw: " + str(_targettingInfo.yawDegrees) + "\n"
	Main.playerDebug = txt
	
	# update status info for UI
	_status.bullets = _inventory.get_count("bullets")
	_status.shells = _inventory.get_count("shells")
	_status.plasma = _inventory.get_count("plasma")
	_status.rockets = _inventory.get_count("rockets")
	_status.yawDegrees = _motor.m_yaw
	_status.health = _health
	_status.energy = _motor.energy
	_status.swayScale = swayScale
	_status.swayTime = _swayTime
	_status.hasInteractionTarget = _interactor.get_is_colliding()
	
	var grp = Groups.PLAYER_GROUP_NAME
	var fn = Groups.PLAYER_FN_STATUS
	get_tree().call_group(grp, fn, _status)

# returns amount taken
func give_item(itemType:String, amount:int) -> int:
	if itemType == "health":
		if _health >= MAX_HEALTH:
			return 0
		_health += amount
		if _health > MAX_HEALTH:
			_health = MAX_HEALTH
		return amount
	var took:int = _inventory.give_item(itemType, amount)
	# if took > 0:
	# 	pass
	#	print("Player took " + itemType + " x " + str(took))
	#	print(_inventory.debug())
	return took

func hit(hitInfo) -> int:
	if hitInfo.attackTeam == Interactions.TEAM_PLAYER:
		return 0
	if _dead:
		return 0
	var dmg = hitInfo.damage
	if !_godMode:
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
