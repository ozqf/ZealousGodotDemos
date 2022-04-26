extends AITicker

var _spreadCross = [
	[0, 0],
	[-750, 0],
	[750, 0],
	[-1500, 0],
	[1500, 0],
	[0, -750],
	[0, 750],
	[0, -1500],
	[0, 1500]
]

var _spreadX = [
	[0, 0],
	[-250, 0],
	[250, 0],
	[-750, 0],
	[750, 0],
	[-1000, 0],
	[1000, 0],
	[-1500, 0],
	[1500, 0],
]

var _spreadY = [
	[0, 0],
	[0, -250],
	[0, 250],
	[0, -750],
	[0, 750],
	[0, -1000],
	[0, 1000],
	[0, -1500],
	[0, 1500],
]

var _attackCount:int = 0

func _fire_spread_prj(origin:Vector3, forward:Vector3) -> void:
	var prj = Game.prj_point_t.instance()
	Game.get_dynamic_parent().add_child(prj)
	prj.maxSpeed = 20
	prj.launch_prj(origin, forward, 0, Interactions.TEAM_ENEMY, Interactions.get_enemy_prj_mask())

func _fire_attack(attack:MobAttack, tarPos:Vector3) -> void:
	if attack.name == "attack":
		attack.fire(tarPos)
		return
	
	var spread = _spreadCross
	if _attackCount % 2 == 0:
		spread = _spreadX
	else:
		spread = _spreadY
	var t:Transform = _mob.head.global_transform
	for _i in range(0, spread.size()):
		var forward:Vector3 = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, spread[_i][0], spread[_i][1])
		_fire_spread_prj(t.origin, forward)
	_attackCount += 1
