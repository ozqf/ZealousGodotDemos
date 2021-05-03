extends InvWeapon

export var empty_animation:String = ""
export var _isAttacking:bool = false

func equip() -> void:
	.equip()
	_hud.centreSprite.offset.y = -60

func deequip() -> void:
	.deequip()
	_hud.centreSprite.offset.y = 0
	_isAttacking = false

func read_input(_primaryOn:bool, _secondaryOn:bool) -> void:
	if tick > 0:
		return
	if _primaryOn:
		tick = refireTime
		_fire_single(-_launchNode.global_transform.basis.z, 1.5)
		.play_fire_1()
		_isAttacking = true
	else:
		_isAttacking = false

func _process(_delta:float) -> void:
	if tick > 0:
		tick -= _delta
	if _equipped == true && _isAttacking == false && tick <= 0:
		print("Chainsaw to idle")
		.play_idle()
