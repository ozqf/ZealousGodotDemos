extends Spatial
class_name ZEEEntityProxy

var _ent:Entity

func set_entity_info(_info:Dictionary, ent:Entity) -> void:
	_ent = ent
	if !_info:
		# no info passed in
		return
	# init
	pass

func get_label() -> String:
	return _ent.prefabName + ": " + _ent.selfName
