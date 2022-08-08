extends InvWeapon

const REV_UP_TIME:float = 2.0
const REV_DOWN_TIME:float = 4.0
const ATTACK_REFIRE_TIME:float = 0.25

export var empty_animation:String = ""
export var _isAttacking:bool = false

enum State { Idle, Sawing, Launched, Recalling, MeleeRecover }

var _state = State.Idle
var _thrown = null
var _revs:float = 0.0

func write_hud_status(statusDict:PlayerHudStatus) -> void:
	statusDict.currentLoaded = 0
	statusDict.currentLoadedMax = 0
	statusDict.currentAmmo = int(_revs)

func custom_init_b() -> void:
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_SAW
	_hitInfo.comboType = Interactions.COMBO_CLASS_SAWBLADE
	_hudSprite = _hud.hud_get_weapon_sprite("weapon_saw")
	_hudSprite.play(idle)

func equip() -> void:
	.equip()
	#_hudSprite.offset.y = -60
	if _state == State.Launched || _state == State.Recalling:
		.play_empty()
	else:
		_hudSprite.play(idle)

func deequip() -> void:
	.deequip()
	if is_instance_valid(_thrown):
		_thrown.user_switched_weapon()
	#_hudSprite.offset.y = 0
	_isAttacking = false

func change_state(newState) -> void:
	if _state == newState:
		return
	var oldState = _state
	_state = newState
	# print("Saw state: " + str(_state))

	if _state == State.Sawing:
		#.play_fire_1()
		_hudSprite.play(fire_1)
	elif _state == State.Launched:
		# launch sawblade
		if _thrown == null:
			# created a new sawblade
			_thrown = Game.prj_player_saw_t.instance()
			Game.get_dynamic_parent().add_child(_thrown)
		_thrown.launch(_launchNode.global_transform, _revs)
		_revs = 0
		#.play_empty()
		_hudSprite.play("saw_thrown")
		_hudSprite.run_shoot_push()
	elif _state == State.Recalling:
		.play_empty()
	elif _state == State.MeleeRecover:
		return
	else:
		#print("Saw play idle")
		_hudSprite.play(idle)

func _perform_hit(_result:Dictionary, _forward:Vector3) -> int:
	_hitInfo.damage = int(_revs) * 2
	var canHyper:bool = check_can_hyper_attack(10)
	if canHyper:
		_hitInfo.hyperLevel = 1
	else:
		_hitInfo.hyperLevel = 0
	var inflicted:int = ._perform_hit(_result, _forward)
	if inflicted > 0:
		if canHyper:
			_inventory.take_item("rage", 10)
		Game.spawn_blood_spurt(_result.position)
		_hudSprite.run_shoot_push()
		_revs = 0
		# _hudSprite.play(idle)
		change_state(State.MeleeRecover)
		tick = ATTACK_REFIRE_TIME
	return inflicted

func _process(_delta:float) -> void:
	_inventory.chainsawRevs = int(_revs)
	
	if _revs > 0:
		chargeUIMode = 1
	else:
		chargeUIMode = 0
	tick -= _delta
	if _state == State.MeleeRecover:
		if tick > 0:
			return
		change_state(State.Idle)
	if _state == State.Sawing:
		# only allow an attack if revs over some amount or 
		# it just gets stuck at 0 from repeat attacks
		if tick <= 0 && _revs >= 25:
			# set refire first. perform hit may override
			# if a hit is successful
			tick = refireTime
			_fire_single(-_launchNode.global_transform.basis.z, 1.5)
	elif _state == State.Launched:
		_revs = _thrown.revs
		if _thrown.is_in_flight():
			_hudSprite.play("saw_thrown")
		else:
			_hudSprite.play("saw_recall")
		pass
	elif _state == State.Recalling:
		_revs = _thrown.revs
		pass
	
	# update revving
	if _state == State.Sawing:
		if Game.hyperLevel > 0:
			_revs += (100.0 / REV_UP_TIME * 4.0) * _delta
		else:
			_revs += (100.0 / REV_UP_TIME) * _delta
	else:
		_revs -= (100.0 / REV_DOWN_TIME) * _delta
	if _revs > 100:
		_revs = 100
	elif _revs < 0:
		_revs = 0

func read_input(_weaponInput:WeaponInput) -> void:
	if _state == State.MeleeRecover:
		return
	if _state == State.Idle:
		if _weaponInput.primaryOn:
			change_state(State.Sawing)
			return
		elif _weaponInput.secondaryOn && !_weaponInput.secondaryOnPrev:
			change_state(State.Launched)
			return
	elif _state == State.Sawing:
		# primary + secondary launch
		if !_weaponInput.primaryOn:
			change_state(State.Idle)
		elif _weaponInput.secondaryOn:
			change_state(State.Launched)
			return
	elif _state == State.Launched || _state == State.Recalling:
		var result:int = _thrown.read_input(_weaponInput)
		if result == 1:
			change_state(State.Idle)

#func read_input_old(_weaponInput:WeaponInput) -> void:
#	if tick > 0:
#		return
#	if _weaponInput.primaryOn:
#		tick = refireTime
#		_fire_single(-_launchNode.global_transform.basis.z, 1.5)
#		.play_fire_1()
#		_isAttacking = true
#	else:
#		_isAttacking = false
#
#func _process_old(_delta:float) -> void:
#	if tick > 0:
#		tick -= _delta
#	if _equipped == true && _isAttacking == false && tick <= 0:
#		# print("Chainsaw to idle")
#		.play_idle()
