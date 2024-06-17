class_name PlayerAttacks

enum Stance {
	Blade,
	Gun,
	Punch
}

static var _moves:Dictionary = {
	punch_jab_left = {
		damageType = GameMain.DAMAGE_TYPE_PUNCH,
		animations = [ "punch_jab_left" ],
		chainOnAtk1 = "",
		chainOnAtk2 = "punch_spins_test",
		idleAnimation = "punch_idle"
	},
	punch_straight_right = {
		damageType = GameMain.DAMAGE_TYPE_PUNCH,
		animations = [ "punch_straight_right" ],
		idleAnimation = "punch_idle"
	},
	punch_machine_gun = {
		damageType = GameMain.DAMAGE_TYPE_PUNCH,
		animations = [ "punch_machine_gun" ],
		idleAnimation = "punch_idle"
	},
	slash_sequence = {
		damageType = GameMain.DAMAGE_TYPE_SLASH,
		animations = [ "slash_sequence_3", "punch_spin_test" ],
		idleAnimation = "blade_idle"
	},
	double_spin = {
		damageType = GameMain.DAMAGE_TYPE_SLASH,
		animations = [ "double_spin_chain" ],
		idleAnimation = "blade_idle"
	},
	shredder = {
		damageType = GameMain.DAMAGE_TYPE_SLASH,
		animations = [ "shredder" ],
		idleAnimation = "blade_idle"
	}
}

static func get_moves() -> Dictionary:
	for key in _moves.keys():
		_moves[key].name = key
	return _moves
