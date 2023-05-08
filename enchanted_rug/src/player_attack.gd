extends Node

var _projectile_t = preload("res://prefabs/projectiles/projectile.tscn")
var _prjInfo:PrjLaunchInfo = null

var _rightHand:Spatial
var _leftHand:Spatial

var _body:Spatial = null
var _refireTick:float = 0
var _aimPoint:Vector3 = Vector3()

func _ready():
	_rightHand = get_parent().get_node("head/attack")
	_leftHand = get_parent().get_node("head/attack2")
	_prjInfo = Main.new_prj_info()

func set_aim_point(pos:Vector3) -> void:
	_aimPoint = pos

func _get_projectile_instance(type:int):
	return _projectile_t.instance()

func _fire(launchNode:Spatial, prjType:int = 0, spreadX:float = 0, spreadY:float = 0) -> void:
	var t:Transform = launchNode.global_transform
	var forward:Vector3 = -t.basis.z
	var pos:Vector3 = t.origin + forward
	if spreadX != 0 || spreadY != 0:
		forward = ZqfUtils.calc_forward_spread_from_basis(pos, t.basis, spreadX, spreadY)
	var prj = _get_projectile_instance(0)
	get_tree().get_current_scene().add_child(prj)
	
	_prjInfo.origin = pos
	_prjInfo.forward = forward
	_prjInfo.target = _aimPoint
	_prjInfo.teamId = Interactions.TEAM_PLAYER

	prj.speed = 200.0

	prj.prj_launch(_prjInfo)

func _process(_delta:float) -> void:
	if _refireTick <= 0:
		if Input.is_action_pressed("attack_1"):
			_refireTick = 0.1
			_rightHand.look_at(_aimPoint, Vector3.UP)
			_leftHand.look_at(_aimPoint, Vector3.UP)
			_fire(_rightHand, 0)
			_fire(_leftHand, 0)
			var x:float = 700
			var y:float = 400
			for _i in range(0, 5):
				var sx:float = 0
				var sy:float =0
				sx = rand_range(-x, x)
				sy = rand_range(-y, y)
				_fire(_rightHand, 0, sx, sy)
				sx = rand_range(-x, x)
				sy = rand_range(-y, y)
				_fire(_leftHand, 0, sx, sy)
			
	else:
		_refireTick -= _delta
