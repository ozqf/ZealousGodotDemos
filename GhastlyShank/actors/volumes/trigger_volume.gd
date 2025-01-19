extends Area3D

func restore(dict:Dictionary) -> void:
	var t:Transform3D = ZqfUtils.Transform3D_from_dict(dict.xform)
	self.global_transform = t
