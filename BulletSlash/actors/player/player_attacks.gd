class_name PlayerAttacks

const FIELD_DAMAGE_TYPE:String = "damageType"
const FIELD_IDLE_ANIMATION:String = "idleAnimation"
const FIELD_SHOTS_CONSUMED_ON_LOOP:String = "shotsConsumedOnLoop"

enum Stance {
	Blade,
	Gun,
	Punch
}

static var _moves:Dictionary = {
	reload_loop = {
		animations = [ "blaster_reload" ],
		idleAnimation = "blaster_idle"
	},
	punch_jab_left = {
		damageType = GameMain.DAMAGE_TYPE_PUNCH,
		animations = [ "punch_jab_left" ],
		#chainOnAtk1 = "",
		#chainOnAtk2 = "punch_spins_test",
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
		idleAnimation = "punch_idle",
		shotsConsumedOnLoop = 1
	},
	slash_sequence = {
		damageType = GameMain.DAMAGE_TYPE_SLASH,
		animations = [ "slash_sequence_1", "slash_sequence_3" ],
		idleAnimation = "blade_idle"
	},
	hold_forward_spin = {
		damageType = GameMain.DAMAGE_TYPE_SLASH,
		animations = [ "punch_spin_test" ],
		idleAnimation = "blade_idle",
		shotsConsumedOnLoop = 1
	},
	double_spin = {
		damageType = GameMain.DAMAGE_TYPE_SLASH,
		animations = [ "double_spin_chain" ],
		idleAnimation = "blade_idle",
		shotsConsumedOnLoop = 2
	},
	shredder = {
		damageType = GameMain.DAMAGE_TYPE_SLASH,
		animations = [ "shredder" ],
		idleAnimation = "punch_idle",
		shotsConsumedOnLoop = 1
	}
}

static func get_moves() -> Dictionary:
	for key in _moves.keys():
		var move:Dictionary = _moves[key]
		# assign its key to its name
		move.name = key

		# set defaults
		if !move.has(FIELD_SHOTS_CONSUMED_ON_LOOP):
			move[FIELD_SHOTS_CONSUMED_ON_LOOP] = 0
		if !move.has(FIELD_DAMAGE_TYPE):
			move[FIELD_DAMAGE_TYPE] = GameMain.DAMAGE_TYPE_SLASH
		if !move.has(FIELD_IDLE_ANIMATION):
			move[FIELD_IDLE_ANIMATION] = "punch_idle"
	return _moves
