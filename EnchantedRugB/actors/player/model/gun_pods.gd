extends Node3D
class_name GunPods

@onready var _animator:AnimationPlayer = $AnimationPlayer
@onready var _right:Node3D = $right
@onready var _left:Node3D = $left

func get_right() -> Node3D:
	return _right

func get_left() -> Node3D:
	return _left

func update_yaw(_degrees:float) -> void:
	# _lastReceivedYaw = _degrees
	# if is_attacking():
	# 	return
	self.rotation_degrees = Vector3(0, _degrees, 0)
	pass

func update_aim_point(aimPoint:Vector3) -> void:
	_right.look_at(aimPoint, Vector3.UP)
	_left.look_at(aimPoint, Vector3.UP)

func _process(_delta) -> void:
	pass