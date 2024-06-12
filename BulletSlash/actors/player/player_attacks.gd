class_name PlayerAttacks

enum Stance {
	Punch,
	Gun
}

static var _moves:Dictionary = {
	punch_jab_left = {
		damageType = GameMain.DAMAGE_TYPE_PUNCH,
		animations = [ "punch_jab_left" ],
		idleAnimation = "punch_idle"
	},
	slash_sequence_2 = {
		damageType = GameMain.DAMAGE_TYPE_SLASH,
		animations = [ "slash_sequence_2", "double_spin_chain" ],
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
