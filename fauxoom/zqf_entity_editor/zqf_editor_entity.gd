extends Spatial

var templateName:String = ""

func write() -> Dictionary:
	return {
		type = templateName,
		xform = ZqfUtils.transform_to_dict(global_transform)
	}

func read(dict:Dictionary) -> void:
	templateName = dict.type
	global_transform = ZqfUtils.transform_from_dict(dict.xform)
