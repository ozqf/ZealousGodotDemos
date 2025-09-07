extends Node3D

@onready var _rope:Node3D = $rope

func face_hang_target(node:Node3D) -> void:
	_rope.look_at(node.global_position, Vector3.BACK)
	
