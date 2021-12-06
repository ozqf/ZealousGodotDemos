extends InvWeapon

var _prj_player_saw_t = preload("res://prefabs/dynamic_entities/prj_player_saw.tscn")

export var empty_animation:String = ""
export var _isAttacking:bool = false

enum State { Idle, Sawing, Launched, Recalling }

var _state = State.Idle
var _thrown = null

func custom_init_b() -> void:
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_SAW

func equip() -> void:
	.equip()
	_hud.centreSprite.offset.y = -60

func deequip() -> void:
	.deequip()
	_hud.centreSprite.offset.y = 0
	_isAttacking = false

func change_state(newState) -> void:
	if _state == newState:
		return
	var oldState = _state
	_state = newState

	if _state == State.Sawing:
		.play_fire_1()
	elif _state == State.Launched:
		# launch sawblade
		if _thrown == null:
			# created a new sawblade
			_thrown = _prj_player_saw_t.instance()
			Game.get_dynamic_parent().add_child(_thrown)
		_thrown.launch(_launchNode.global_transform)
	elif _state == State.Recalling:
		pass
	else:
		.play_idle()

func _process(_delta:float) -> void:
	tick -= _delta
	if _state == State.Sawing:
		if tick <= 0:
			_fire_single(-_launchNode.global_transform.basis.z, 1.5)
			tick = refireTime
	elif _state == State.Launched:
		pass
	elif _state == State.Recalling:
		pass
	else:
		pass
	pass

func read_input(_primaryOn:bool, _secondaryOn:bool) -> void:
	if _state == State.Idle:
		if _primaryOn:
			change_state(State.Sawing)
			return
		elif _secondaryOn:
			change_state(State.Launched)
			return
	elif _state == State.Sawing:
		if !_primaryOn:
			change_state(State.Idle)
	elif _state == State.Launched || _state == State.Recalling:
		var result:int = _thrown.read_input(_primaryOn, _secondaryOn)
		if result == 1:
			change_state(State.Idle)

func read_input_old(_primaryOn:bool, _secondaryOn:bool) -> void:
	if tick > 0:
		return
	if _primaryOn:
		tick = refireTime
		_fire_single(-_launchNode.global_transform.basis.z, 1.5)
		.play_fire_1()
		_isAttacking = true
	else:
		_isAttacking = false

func _process_old(_delta:float) -> void:
	if tick > 0:
		tick -= _delta
	if _equipped == true && _isAttacking == false && tick <= 0:
		# print("Chainsaw to idle")
		.play_idle()
