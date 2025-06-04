extends StaticBody3D
class_name PlayerBarrierVolume

@onready var _shape:CollisionShape3D = $CollisionShape3D

func set_active(flag:bool) -> void:
	_shape.disabled = !flag
	self.visible = flag
