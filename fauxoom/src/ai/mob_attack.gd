extends Node
class_name MobAttack

# var _prj_point_t = load("res://prefabs/projectiles/prj_point.tscn")

@export var tag:String = ""
# flag to force this mob attack from being selected automatically.
@export var enabled:bool = true
@export var minUseRange:float = 0
@export var maxUseRange:float = 9999
@export var attackCount:int = 1

@export var windUpTime:float = 0.25
@export var windDownTime:float = 0.25
@export var repeatTime:float = 0.1
@export var attackAnimTime:float = 0.1

@export var showAimLaser:bool = false
@export var showAimLaserDuringRepeat:bool = false
@export var showOmniCharge:bool = false
@export var allowMovement:bool = true

# TODO - implement attack cooldowns
# make this attack unusable for the duration, and other attacks
# must be used instead. Stops enemies from spamming powerful attacks
@export var cooldown:float = 0
var lastSelectTime:float = 0
# limits number of times this mob can fire this attack
@export var ammo:int = -1

@export var faceTargetDuringWindup:bool = true
@export var faceTargetDuringAttack:bool = true
@export var requiresLos:bool = true
@export var useLastSeenPosition:bool = true
@export var ignoreAutoSelect:bool = false

# eg 
var prjPrefabOverride = null

# set by mob when attacks are collected
var index:int = 0

var _launchNode:Node3D = null
var _body:Node3D = null
var _pattern:Pattern = null

var _tick:float = 0
var _repeats:int = 1
var _attackWindupTime:float = 0.3 # 0.5
var _attackRecoverTime:float = 0.3 # 0.5
var _prjMask:int = -1

var _patternBuffer

func custom_init(launchNode:Node3D, body:Node3D) -> void:
	_launchNode = launchNode
	_body = body
	_prjMask = Interactions.get_enemy_prj_mask()
	_pattern = get_node_or_null("pattern") as Pattern
	# allocate buffer for pattern if necessary
	if _pattern != null:
		_patternBuffer = []
		for _i in range(0, 256):
			_patternBuffer.push_back({
				pos = Vector3(),
				forward = Vector3()
			})

func _tick_down(_delta:float) -> bool:
	_tick -= _delta
	return (_tick <= 0)

func cancel() -> void:
	pass

func fire_from(_target:Vector3, launch:Node3D, _spinDegrees:float = 0.0) -> void:
	# print("Fire!")
	
	var t:Transform3D = launch.global_transform
	var selfPos:Vector3 = t.origin
	var forward:Vector3 = -t.basis.z

	if _pattern == null:
		var prj = null
		if prjPrefabOverride == null:
			prj = Game.get_factory().prj_point_t.instance()
		else:
			prj = prjPrefabOverride.instance()
		Game.get_dynamic_parent().add_child(prj)
		prj.launch_prj(selfPos, forward, 0, Interactions.TEAM_ENEMY, _prjMask)
		if _spinDegrees != 0.0:
			var rot:Vector3 = prj.rotation_degrees
			rot.z = _spinDegrees
			prj.rotation_degrees = rot
		return
	var numItems:int = 0
	numItems = _pattern.fill_items(selfPos, forward, _patternBuffer, numItems)
	# print("Pattern attack got " + str(numItems) + " items")
	for _i in range (0, numItems):
		var item:Dictionary = _patternBuffer[_i]
		var prj = null
		if prjPrefabOverride == null:
			prj = Game.get_factory().prj_point_t.instance()
		else:
			prj = prjPrefabOverride.instance()
		Game.get_dynamic_parent().add_child(prj)
		# var frwd:Vector3 = t.basis.xform_inv(item.forward)
		var frwd:Vector3 = item.forward
		prj.launch_prj(item.pos, frwd, 0, Interactions.TEAM_ENEMY, _prjMask)
		if _spinDegrees != 0.0:
			var rot:Vector3 = prj.rotation_degrees
			rot.z = _spinDegrees
			prj.rotation_degrees = rot

func fire(target:Vector3) -> void:
	fire_from(target, _launchNode)
