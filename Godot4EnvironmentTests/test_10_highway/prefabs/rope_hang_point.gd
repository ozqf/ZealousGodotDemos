extends Node3D

@onready var _rope:Node3D = $rope

func face_hang_target(globalPos:Vector3) -> void:
	_rope.look_at(globalPos, Vector3.BACK)
	
