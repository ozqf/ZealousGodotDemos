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

var _spreadCrossSmall = [
	[0, 0],
	[-250, 0],
	[250, 0],
	[-500, 0],
	[500, 0],
	
	[0, -350],
	[0, 350],
	[0, -700],
	[0, 700]
]

var _spreadCrossthin = [
	[0, 0],
	[-750, 0],
	[750, 0],
#	[-1500, 0],
#	[1500, 0],
	[0, -750],
	[0, 750],
	[0, -1500],
	[0, 1500]
]

var _spreadX = [
	[0, 0],
	# [-250, 0],
	# [250, 0],
	# [-750, 0],
	# [750, 0],
	# [-1000, 0],
	# [1000, 0],
	# [-2000, 0],
	# [2000, 0],
	[-4000, 0],
	[4000, 0],
]

var _spreadY = [
	[0, 0],
	# [0, -250],
	# [0, 250],
	[0, -750],
	[0, 750],
	# [0, -1000],
	# [0, 1000],
	[0, -1500],
	[0, 1500],
]

var _spreadCircle

var _attackCount:int = 0
var _prjSpeed:float = 20

func _ready() -> void:
	# _spreadCircle = _build_circular_offsets()
	_spreadCircle = ZqfSpawnPatterns.build_cone_offsets(3000, 24)

# func _build_circular_offsets():
# 	var radius:float = 3000
# 	var count:int = 24
# 	var step:float = 360.0 / float(count)
# 	var degrees:float = 0.0
# 	var results = []
# 	for _i in range(0, count):
# 		var x:float = cos(deg_to_rad(degrees))
# 		var y:float = sin(deg_to_rad(degrees))
# 		results.push_back([ x * radius, y * radius ])
# 		degrees += step
# 	return results

func _fire_spread_prj(origin:Vector3, forward:Vector3) -> void:
	var prj = Game.get_factory().prj_point_t.instance()
	Game.get_dynamic_parent().add_child(prj)
	prj.maxSpeed = _prjSpeed
	prj.launch_prj(origin, forward, 0, Interactions.TEAM_ENEMY, Interactions.get_enemy_prj_mask())

func _tick_fire_function(_attack:MobAttack, _tarPos:Vector3) -> void:
	var spread = _spreadCross
	if _attackCount % 2 == 0:
		_prjSpeed = 15
		spread = _spreadX
		#spread = _spreadCircle
	else:
		_prjSpeed = 15
		spread = _spreadY
		#spread = _spreadCrossSmall
	var t:Transform3D = _mob.head.global_transform
	for _i in range(0, spread.size()):
		var forward:Vector3 = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, spread[_i][0], spread[_i][1])
		_fire_spread_prj(t.origin, forward)
	_attackCount += 1

func _fire_attack(attack:MobAttack, tarPos:Vector3) -> void:
	if attack.name == "attack":
		attack.fire(tarPos)
		return
	_tick_fire_function(attack, tarPos)
	#_tick_fire_function(attack, tarPos)
