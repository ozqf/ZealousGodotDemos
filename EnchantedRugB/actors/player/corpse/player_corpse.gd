extends Node

@onready var _dollTop:RigidBody3D = $doll_top
@onready var _dollBottom:RigidBody3D = $doll_bottom
@onready var _cam:Camera3D = $Camera3D

func spawn(_origin:Transform3D, _cameraT:Transform3D) -> void:
	_cam.global_transform = _cameraT
	_dollTop.global_position = _origin.origin
	_dollBottom.global_position = _origin.origin
	
	_dollTop.linear_velocity.y = 15
	_dollTop.angular_velocity = Vector3(randf_range(20, 50), 0, 0)
