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

func _fire(launchNode:Spatial) -> void:
	var pos:Vector3 = launchNode.global_transform.origin
	var forward:Vector3 = -launchNode.global_transform.basis.z
	var prj = _projectile_t.instance()
	get_tree().get_current_scene().add_child(prj)
	
	_prjInfo.origin = pos
	_prjInfo.forward = forward
	_prjInfo.target = _aimPoint
	prj.prj_launch(_prjInfo)

func _process(_delta:float) -> void:
	if _refireTick <= 0:
		if Input.is_action_pressed("attack_1"):
			_refireTick = 0.1
			_rightHand.look_at(_aimPoint, Vector3.UP)
			_leftHand.look_at(_aimPoint, Vector3.UP)
			_fire(_rightHand)
			_fire(_leftHand)
	else:
		_refireTick -= _delta
