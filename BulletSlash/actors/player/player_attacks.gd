class_name PlayerAttacks

enum Stance {
	Punch,
	Gun
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
	slash_sequence_2 = {
		damageType = GameMain.DAMAGE_TYPE_SLASH,
		animations = [ "slash_sequence_2", "punch_spin_test" ],
		idleAnimation = "punch_idle"
	},
	double_spin_chain = {
		damageType = GameMain.DAMAGE_TYPE_SLASH,
		animations = [ "double_spin_chain" ],
		idleAnimation = "punch_idle"
	},
	shredder = {
		damageType = GameMain.DAMAGE_TYPE_SLASH,
		animations = [ "shredder" ],
		idleAnimation = "punch_idle"
	}
}

static func get_moves() -> Dictionary:
	for key in _moves.keys():
		_moves[key].name = key
	return _moves
