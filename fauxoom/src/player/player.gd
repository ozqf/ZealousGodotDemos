extends KinematicBody
class_name Player

var _player_hud_status_t = preload("res://src/defs/player_hud_status.gd")

const MAX_HEALTH:int = 100

onready var _ent:Entity = $Entity
onready var _head:Spatial = $head
onready var _cameraMount:Spatial = $camera_mount
onready var _motor:ZqfFPSMotor = $motor
onready var _attack:PlayerAttack = $attack
onready var _inventory = $inventory
onready var _hud:Hud = $hud
onready var _interactor:PlayerObjectInteractor = $head/interaction_ray_cast
onready var _flashLight:SpotLight = $head/SpotLight
onready var _muzzleFlash:OmniLight = $head/muzzle_flash
onready var _aimRay:RayCast = $head/aim_ray_cast
onready var _laserDot:Spatial = $head/laser_dot
onready var _wallDetector:ZqfVolumeScanner = $wall_detector

var _inputOn:bool = false

var _gameplayInputOn:bool = true
var _appInputOn:bool = true

var _startTransform:Transform = Transform.IDENTITY
var _recoverTransform:Transform = Transform.IDENTITY

var _godMode:bool = false
var _dead:bool = false
var _health:int = MAX_HEALTH
var _swayTime:float = 0.0
var _hudStatus:PlayerHudStatus = null
var _targetHealthInfo:MobHealthInfo = null

var _hyperCooldown:float = 0
var _hyperLevel:int = 0
var _hyperTime:float = 0
var _bonus:int = 0
var _bonusReductionTick:float = 0.0

var _targettingInfo:Dictionary = {
	id = Interactions.PLAYER_RESERVED_ID,
	position = Vector3(),
	forward = Vector3(),
	flatVelocity = Vector3(),
	flatForward = Vector3(),
	yawDegrees = 0,
	aimPos = Vector3(),
	noAttackTime = 0.0,
	health = 100
}

func _ready():
	add_to_group(Config.GROUP)
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	add_to_group(Groups.PLAYER_GROUP_NAME)
	
	_hudStatus = _player_hud_status_t.new()
	_targetHealthInfo = Game.new_mob_health_info()
	
	_motor.init_motor(self, _head)
	_motor.set_input_enabled(false)
	_inventory.connect("weapon_changed", _hud, "inventory_weapon_changed")
	_inventory.connect("weapon_action", self, "on_weapon_action")
	_inventory.custom_init(_head, self, _hud)
	_inventory.ownerId = Interactions.PLAYER_RESERVED_ID
	_attack.init_attack(_interactor, _inventory)
	_attack.set_attack_enabled(false)
	
	var _result
	# _result  = _attack.connect("fire", _hud, "on_player_shoot")
	# _result = _attack.connect("fire", self, "on_player_shoot")
	# _result = _attack.connect("change_weapon", _hud, "on_change_weapon")
	_result = connect("tree_exiting", self, "_on_tree_exiting")
	_result = _ent.connect("entity_append_state", self, "append_state")
	_result = _ent.connect("entity_restore_state", self, "restore_state")
	_result = _motor.connect("moved", self, "on_moved")

	Game.register_player(self)
	config_changed(Config.cfg)

func on_player_shoot() -> void:
	# _audio.play()
	pass

func on_moved(body, head) -> void:
	var grp:String = Groups.PLAYER_GROUP_NAME
	var fn:String = Groups.PLAYER_FN_MOVED
	get_tree().call_group(grp, fn, body, head)
	pass

func player_ground_slam_start() -> void:
	print("Player - slam!")
	_motor.start_ground_slam()

func on_weapon_action(_weapon:InvWeapon, _action:String) -> void:
	_muzzleFlash.show_for_time(0.1)

func append_state(_dict:Dictionary) -> void:
	var t:Transform = Transform.IDENTITY
	t.origin = self.global_transform.origin
	t.basis = _head.global_transform.basis
	_dict.xform = ZqfUtils.transform_to_dict(t)
	print("Player saving pos " + str(t.origin))
	_inventory.append_state(_dict)

func restore_state(_dict:Dictionary) -> void:
	var t:Transform = ZqfUtils.transform_from_dict(_dict.xform)
	print("Player restoring to pos " + str(t.origin))
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
	print("Player position: " + str(self.global_transform.origin))
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
		var txt = _inventory.debug()
		print(txt)
	# ai test find melee
	if _txt == "findplayer":
		var dest:Vector3 = global_transform.origin
		var to:Vector3 = AI.find_closest_navmesh_point(dest)
		AI.set_test_nav_dest(to)

	if _txt == "findmelee":
		var agent:NavAgent = AI.create_nav_agent()
		agent.position = global_transform.origin
		if AI.find_melee_position(agent):
			print("Melee target " + str(agent.objectiveNode.index) + " at " + str(agent.target))
			AI.set_test_nav_dest(agent.target)
			var navPos:Vector3 = AI.find_closest_navmesh_point(agent.target)
			print("Closest nav pos " + str(navPos))
		else:
			print("No viable Melee target")
	elif _txt == "findsnipe":
		var agent:NavAgent = AI.create_nav_agent()
		agent.position = global_transform.origin
		if AI.find_sniper_position(agent):
			var path = AI.get_path_to_point(agent.position, agent.target)
			AI.debug_path(path)
		else:
			print("No viable snipe point")
	# ai test find flee
	elif _txt == "findflee":
		var agent:NavAgent = AI.create_nav_agent()
		agent.position = global_transform.origin
		# var agent:Dictionary = {
		# 	position = global_transform.origin,
		# 	target = Vector3(),
		# 	nodeIndex = -1
		# }
		if AI.find_flee_position(agent):
			print("Flee target " + str(agent.objectiveNode.index) + " at " + str(agent.target))
			AI.set_test_nav_dest(agent.target)
			var navPos:Vector3 = AI.find_closest_navmesh_point(agent.target)
			print("Closest nav pos " + str(navPos))
			var path = AI.get_path_to_point(agent.position, agent.target)
			AI.debug_path(path)
		else:
			print("No viable flee target")

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

func _spawn_aoe() -> HyperAoe:
	var aoe = Game.hyper_aoe_t.instance()
	Game.get_dynamic_parent().add_child(aoe)
	aoe.global_transform.origin = _head.global_transform.origin
	return aoe

func _hyper_on() -> void:
	_hyperLevel = 1
	# no rage cost currently, just a minimum to activate
	# _inventory.take_item("rage", Interactions.HYPER_COST)
	_hyperTime = 0.0
	var aoe = _spawn_aoe()
	aoe.run_hyper_aoe(HyperAoe.TYPE_HYPER_ON, 0.0)

func _tick_hyper(_delta:float) -> void:
	if _hyperCooldown > 0:
		_hyperCooldown -= _delta
	var prevLevel:int = _hyperLevel
	var keyPressed:bool = Input.is_action_just_pressed("hyper")
	var cost:int = Interactions.HYPER_COST
	var duration:float = Interactions.HYPER_DURATION
	if _hyperLevel <= 0:
		if keyPressed && _inventory.get_count("rage") >= cost && _hyperCooldown <= 0:
			_hyper_on()
		pass
	else:
		# consume rage
		_hyperTime -= _delta
		if _hyperTime <= 0:
			_hyperTime = Interactions.HYPER_COST_TICK_TIME
			# take rage... if none could be taken, exit hyper
			if _inventory.take_item("rage", Interactions.HYPER_COST_PER_TICK)  == -1:
				# ran out of rage
				_hyperLevel = 0
				_hyperCooldown = Interactions.HYPER_COOLDOWN_DURATION
		elif keyPressed:
			# forced cancel
			_hyperLevel = 0
			var aoe = _spawn_aoe()
			var weight:float = _hyperTime / Interactions.HYPER_DURATION
			aoe.run_hyper_aoe(HyperAoe.TYPE_HYPER_CANCEL, weight)
			_hyperCooldown = Interactions.HYPER_COOLDOWN_DURATION
		#elif _hyperTime <= 0:
		#	# timeout
		#	_hyperLevel = 0
		#	var aoe = _spawn_aoe()
		#	aoe.run_hyper_aoe(HyperAoe.TYPE_HYPER_OFF, 0.0)
		#	_hyperCooldown = 10.0
	# update?
	if _hyperLevel != prevLevel:
		_inventory.update_hyper_level(_hyperLevel)
	Game.hyperLevel = _hyperLevel

func _tick_bonus(_delta:float) -> void:
	if _bonus > 0:
		_bonusReductionTick -= _delta
		if _bonusReductionTick <= 0.0:
			_bonusReductionTick = 2.0
			_bonus -= 1

func _process(_delta:float) -> void:
	_refresh_input_on()
	
	if _wallDetector.bodies.size() > 0:
		_motor.nearWall = true
	else:
		_motor.nearWall = false
	
	_tick_hyper(_delta)
	_tick_bonus(_delta)
	# if _appInputOn && _gameplayInputOn && Input.is_action_just_pressed("interact"):
	# 	_interactor.use_target()
	if Input.is_action_just_pressed("flash_light"):
		_flashLight.visible = !_flashLight.visible
	
	# laser dot
	var aimPos:Vector3
	_hudStatus.targetHealth = -1
	if _aimRay.is_colliding():
		aimPos = _aimRay.get_collision_point()
		var obj = _aimRay.get_collider()
		# had an invalid instance here whilst testing
		# during a hectic fight, so check for that :/
		if is_instance_valid(obj) && obj.has_method("fill_health_info"):
			obj.fill_health_info(_targetHealthInfo)
			_hudStatus.targetHealth = _targetHealthInfo.healthPercentage
			_hudStatus.targetVulnerable = _targetHealthInfo.closeToDeath
			_hudStatus.targetInvulnerable = _targetHealthInfo.invulnerable
	else:
		var headForward:Vector3 = -_head.global_transform.basis.z
		aimPos = _head.global_transform.origin + (headForward * 1000)
	_laserDot.global_transform.origin = aimPos

	# write targetting information
	_targettingInfo.position = _head.global_transform.origin
	_targettingInfo.yawDegrees = _motor.m_yaw
	_targettingInfo.forward = -_head.global_transform.basis.z
	_targettingInfo.flatForward = ZqfUtils.yaw_to_flat_vector3(_motor.m_yaw)
	_targettingInfo.velocity = _motor.get_velocity()
	_targettingInfo.aimPos = aimPos
	_targettingInfo.flatVelocity = _motor.get_flat_velocity()
	_targettingInfo.noAttackTime = _attack.noAttackTime
	_targettingInfo.health = _health

	# Write HUD information
	var t:Transform = _head.transform
	var swayScale:float = _motor.get_sway_scale()
	_swayTime += (_delta * (swayScale * 12))
	# if _motor.get_velocity().length() > 0:
	#	_swayTime += (_delta * 12)
	t.origin.y += sin(_swayTime) * 0.025
	_cameraMount.transform = t
	
	var txt = ""
	txt = "real forward: " + str(_targettingInfo.forward) + "\n"
	txt += "pos: " + str(_targettingInfo.position) + "\n"
	txt += "yaw: " + str(_targettingInfo.yawDegrees) + "\n"
	Main.playerDebug = txt
	
	# update status info for UI
	
	_hudStatus.yawDegrees = _motor.m_yaw
	_hudStatus.health = _health
	_hudStatus.energy = int(_motor.energy)
	_hudStatus.swayScale = swayScale
	_hudStatus.swayTime = _swayTime
	_hudStatus.godMode = _godMode
	_hudStatus.hasInteractionTarget = _interactor.get_is_colliding()
	_hudStatus.hyperLevel = _hyperLevel
	# _hudStatus.hyperTime = _hyperTime
	_hudStatus.hyperTime = _hyperCooldown
	_hudStatus.bonus = _bonus
	_hudStatus.isNearWall = _motor.nearWall

	# calculate hyper cost per second and therefore remaining seconds
	var costPerSecond:float = 1.0 / Interactions.HYPER_COST_TICK_TIME
	_hudStatus.hyperSecondsRemaining = float(_inventory.get_count("rage")) / costPerSecond

	_inventory.write_hud_status(_hudStatus)

	_attack.write_hud_status(_hudStatus)
	
	var grp = Groups.PLAYER_GROUP_NAME
	var fn = Groups.PLAYER_FN_STATUS
	get_tree().call_group(grp, fn, _hudStatus)

# returns amount taken
func give_item(itemType:String, amount:int) -> int:
	# is this something this class is interested in?
	if itemType == "health":
		if _health >= MAX_HEALTH:
			return 0
		_health += amount
		if _health > MAX_HEALTH:
			_health = MAX_HEALTH
		return amount
	
	# we always take bonuses
	if itemType == "bonus":
		_bonus += amount
		return amount
	
	# maybe it is an inventory item...?
	var took:int = _inventory.give_item(itemType, amount)
	# if took > 0:
	# 	pass
	#	print("Player took " + itemType + " x " + str(took))
	#	print(_inventory.debug())
	return took

func _send_hit_message(dmg, direction, healthType) -> void:
	var grp:String = Groups.PLAYER_GROUP_NAME
	var fn:String = Groups.PLAYER_FN_HIT
	var data:Dictionary = {
		damage = dmg,
		direction = direction,
		selfYawDegrees = _motor.m_yaw,
		healthType = healthType
	}
	get_tree().call_group(grp, fn, data)

func hit(hitInfo:HitInfo) -> int:
	if hitInfo.attackTeam == Interactions.TEAM_PLAYER:
		return 0
	if _dead:
		return 0
	if _godMode && hitInfo.damageType != Interactions.DAMAGE_TYPE_VOID:
		# _health -= dmg
		return 0
	var dmg = hitInfo.damage
	
	if _hyperLevel > 0 && hitInfo.damageType != Interactions.DAMAGE_TYPE_VOID:
		# in hyper, rage absorbs damage
		var taken:int = _inventory.take_item("rage", dmg)
		# if we ran out,
		if _inventory.get_count("rage") == 0:
			# exit hyper and for this hit we ignore the rest of the damage
			# because we are nice
			_hyperLevel = 0
			_hyperCooldown = 10.0
			var aoe = _spawn_aoe()
			aoe.run_hyper_aoe(HyperAoe.TYPE_HYPER_OFF, 0.0)
		_send_hit_message(dmg, hitInfo.direction, 1)
		return dmg
	
	# taking actual health, deary me
	_health -= dmg

	if _health <= 0:
		# check for hyper save
		if _hyperLevel == 0 && _inventory.get_count("rage") > 20:
			_health = 1
			_hyper_on()
			return dmg
		else:
			kill()
		return dmg + _health
	else:
		_send_hit_message(dmg, hitInfo.direction, 0)
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

func void_volume_touch() -> void:
	kill()
