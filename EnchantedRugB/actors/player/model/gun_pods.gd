extends Node3D
class_name GunPods

var _prjBasicType = preload("res://projectiles/basic/prj_basic.tscn")

@onready var _animator:AnimationPlayer = $AnimationPlayer
@onready var _right:Node3D = $right
@onready var _left:Node3D = $left

var _tick:float = 0.0

func get_right() -> Node3D:
	return _right

func get_left() -> Node3D:
	return _left

func set_show_lasers(flag:bool) -> void:
	_right.visible = flag
	_left.visible = flag

func update_yaw(_degrees:float) -> void:
	# _lastReceivedYaw = _degrees
	# if is_attacking():
	# 	return
	self.rotation_degrees = Vector3(0, _degrees, 0)
	pass

func update_aim_point(aimPoint:Vector3) -> void:
	_right.look_at(aimPoint, Vector3.UP)
	_left.look_at(aimPoint, Vector3.UP)

func _physics_process(delta) -> void:
	_tick -= delta
	pass

func _fire_projectile(node:Node3D, typeObj) -> void:
	var prj = typeObj.instantiate()
	Zqf.get_actor_root().add_child(prj)
	prj.get_hit_info().teamId = Game.TEAM_ID_PLAYER
	prj.launch(node.global_position, -node.global_transform.basis.z)

func read_input(_input:PlayerInput) -> bool:
	if _input.attack1:
		if _tick <= 0:
			_tick = 0.1
			_fire_projectile(_right, _prjBasicType)
			_fire_projectile(_left, _prjBasicType)
		return false
	return false
