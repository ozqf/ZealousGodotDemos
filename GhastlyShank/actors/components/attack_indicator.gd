extends Node3D
class_name AttackIndicator

func refresh(weight:float) -> void:
	var sx:float = lerpf(0, 1, weight)
	self.scale = Vector3(sx, sx, sx)
