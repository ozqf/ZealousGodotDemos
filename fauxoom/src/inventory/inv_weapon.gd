 extends Node
class_name InvWeapon

signal weapon_action(weapon, actionName)

export var damageType:int = 0
export var hudName:String = ""
export var inventoryType:String = ""
export var ammoType:String = ""
export var ammoPerShot:int = 1
export var slot:int = 1

export var refireTime:float = 0.25

export var idle:String = ""
export var fire_1:String = ""
export var reload:String = ""
export var empty:String = ""

export var akimbo:bool = false
export var heaviness:int = 0

var chargeUIMode:int = 0

# acquired from HUD at startup
var _hudSprite:HudWeaponSprite

var _equipped:bool = false
var _launchNode:Spatial = null
var _ignoreBody = []
var _hud = null
# want to strongly type but can't
var _inventory = null
var _hitInfo:HitInfo = null
var _leftNext:bool = false
var _lastFireSingleHit:bool = false

var tick:float = 0
var hyperLevel:int = 0

#########################################
# init and select/deselect logic
#########################################
func custom_init(inventory, launchNode:Spatial, ignoreBody:PhysicsBody, hud) -> void:
	_launchNode = launchNode
	_inventory = inventory
	_ignoreBody = [ ignoreBody ]
	_hitInfo = Game.new_hit_info()
	_hud = hud
	# default - should be overridden by weapon implementation
	_hudSprite = _hud.hud_get_weapon_sprite("weapon_centre")
	custom_init_b()

# overload this function to add additional custom setup
func custom_init_b() -> void:
	pass

func write_hud_status(statusDict:PlayerHudStatus) -> void:
	statusDict.currentLoaded = 0
	statusDict.currentLoadedMax = 0
	statusDict.currentAmmo = _inventory.get_count(ammoType)

func can_equip() -> bool:
	if inventoryType == "":
		return true
	var weaponCount:int = _inventory.get_count(inventoryType)
	if weaponCount == 0:
		return false
	var ammoCount:int = _inventory.get_count(ammoType)
	if ammoCount == -1:
		return true
	return ammoCount >= ammoPerShot

func equip() -> void:
	# print("Equip " + self.name)
	_equipped = true
	#play_idle()
	_hud.hide_all_sprites()
	_hudSprite.visible = true

func deequip() -> void:
	_equipped = false

func is_equipped() -> bool:
	return _equipped

func is_cycling() -> bool:
	if hyperLevel > 0:
		return false
	if Game.allowQuickSwitching:
		# quick switch isn't *instant* switching ;)
		if tick <= 0:
			return false
		# if tick <= 0 || tick < refireTime - Game.quickSwitchTime:
		# 	return false
		return tick > (refireTime - Game.quickSwitchTime)
		# return true
	else:
		return tick > 0

func check_can_hyper_attack(cost:int) -> bool:
	if Game.hyperLevel == 0:
		return false
	if _inventory.get_count("rage") < cost:
		return false
	return true

func check_and_use_hyper_attack(cost:int) -> bool:
	if Game.hyperLevel == 0:
		return false
	if _inventory.get_count("rage") < cost:
		return false
	_inventory.take_item("rage", cost)
	return true

#########################################
# default attack logic
#########################################
func play_idle() -> void:
	if idle == null || idle == "":
		return
	_hudSprite.play(idle)
	#get_tree().call_group(
	#	Groups.HUD_GROUP_NAME,
	#	Groups.HUD_FN_PLAY_WEAPON_IDLE,
	#	idle,
	#	akimbo)

func play_fire_1(loop:bool = true) -> void:
	if _hud == null || fire_1 == null || fire_1 == "":
		return
	_hudSprite.play(fire_1)
	_hudSprite.nextAnim = idle
	#get_tree().call_group(
	#	Groups.HUD_GROUP_NAME,
	#	Groups.HUD_FN_PLAY_WEAPON_SHOOT,
	#	fire_1,
	#	idle,
	#	loop,
	#	akimbo,
	#	heaviness)

func play_empty() -> void:
	if empty == null || empty == "" || _hudSprite == null:
		return
	_hudSprite.play(empty)
	# get_tree().call_group(
	# 	Groups.HUD_GROUP_NAME,
	# 	Groups.HUD_FN_PLAY_WEAPON_IDLE,
	# 	empty,
	# 	akimbo)

func read_input(_weaponInput:WeaponInput) -> void:
	pass

func _perform_hit(result:Dictionary, forward:Vector3) -> int:
	#print("HIT at " + str(result.position))
	# result.collider etc etc
	_hitInfo.direction = forward
	_hitInfo.origin = result.position
	var interactionResult:int = Interactions.hitscan_hit(_hitInfo, result)
	var inflicted:int = interactionResult

	var root:Node = get_tree().get_current_scene()
	if inflicted == -1:
		var spritePos:Vector3 = result.position - (forward * 0.2)
		Game.get_factory().spawn_impact_sprite(spritePos)
		# fire debris
		Game.get_factory().spawn_impact_debris(spritePos, result.normal, 2, 12, 3)
	elif inflicted == -2:
		# print("Penetration hit")
		pass
	elif inflicted > 1:
		Sfx.spawn_impact(result.position)
	return inflicted

func _fire_single(forward:Vector3, scanRange:float) -> Vector3:
	var mask:int = Interactions.get_player_prj_mask()
	var origin:Vector3 = _launchNode.global_transform.origin
	var result:Dictionary = ZqfUtils.hitscan_by_direction_3D(_launchNode, origin, forward, scanRange, _ignoreBody, mask)
	var hitPoint:Vector3 = origin + (forward * scanRange)
	if result:
		_perform_hit(result, forward)
		hitPoint = result.position
		_lastFireSingleHit = true
	# perform second scan for debris that will not interfer with the damage scan
	result = ZqfUtils.quick_hitscan3D(_launchNode, scanRange, _ignoreBody, Interactions.get_corpse_hit_mask())
	if result:
		_perform_hit(result, forward)
	return hitPoint
