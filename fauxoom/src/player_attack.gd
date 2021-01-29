extends Node
class_name PlayerAttack

var _prefab_impact = preload("res://prefabs/bullet_impact.tscn")

var _launchNode:Spatial = null
var _parentBody:PhysicsBody = null
var _active:bool = false
var _tick:float = 0

var _refireTime:float = 1
var _extraPellets:int = 10

signal fire_ssg()
signal change_weapon(nameString)

func init_attack(launchNode:Spatial, ignoreBody:PhysicsBody) -> void:
	_launchNode = launchNode
	_parentBody = ignoreBody

func set_attack_enabled(flag:bool) -> void:
	_active = flag

func _perform_hit(result:Dictionary) -> void:
	#print("HIT at " + str(result.position))
	# result.collider etc etc
	var impact:Spatial = _prefab_impact.instance()
	var root:Node = get_tree().get_current_scene()
	root.add_child(impact)
	var t = impact.global_transform
	t.origin = result.position
	impact.global_transform = t

func _fire_spread() -> void:
	# fire single straight forward
	_fire_single()
	var t:Transform = _launchNode.global_transform
	var origin:Vector3 = t.origin
	#var originForward:Vector3 = -t.basis.z
	var mask:int = (1 << 0)
	#var mask:int = -1
	for _i in range(0, _extraPellets):
		var spreadX:float = rand_range(-1000, 1000)
		var spreadY:float = rand_range(-300, 300)
		var forward:Vector3 = ZqfUtils.calc_forward_spread_from_basis(origin, t.basis, spreadX, spreadY)
		var result:Dictionary = ZqfUtils.hitscan_by_pos_3D(_launchNode, origin, forward, 1000, [_parentBody], mask)
		if result:
			_perform_hit(result)

func _fire_single() -> void:
	var mask:int = (1 << 0)
	#var mask:int = -1
	var result = ZqfUtils.quick_hitscan3D(_launchNode, 1000, [_parentBody], mask)
	if result:
		_perform_hit(result)
	pass

func _process(_delta:float) -> void:
	if _tick >= 0:
		_tick -= _delta
		return
	if !_active:
		return
	
	if Input.is_action_just_pressed("slot_1"):
		self.emit_signal("change_weapon", Weapons.PistolLabel)
		_refireTime = 0.3
		_extraPellets = 0
	if Input.is_action_just_pressed("slot_2"):
		self.emit_signal("change_weapon", Weapons.DualPistolsLabel)
		_refireTime = 0.15
		_extraPellets = 0
	if Input.is_action_just_pressed("slot_3"):
		self.emit_signal("change_weapon", Weapons.SuperShotgunLabel)
		_refireTime = 1
		_extraPellets = 10
	if Input.is_action_just_pressed("slot_4"):
		self.emit_signal("change_weapon", Weapons.ChaingunLabel)
		_refireTime = 0.1
		_extraPellets = 2
	if Input.is_action_just_pressed("slot_5"):
		self.emit_signal("change_weapon", Weapons.RocketLauncherLabel)
		_refireTime = 1
		_extraPellets = 0
	
	if Input.is_action_pressed("attack_1") || Input.is_action_pressed("move_special"):
		_tick = _refireTime
		_fire_spread()
		self.emit_signal("fire_ssg")
	
