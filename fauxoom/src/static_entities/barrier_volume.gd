extends Spatial
class_name BarrierVolume

onready var _mesh:MeshInstance = $MeshInstance
onready var _shape:CollisionShape = $CollisionShape
onready var _ent:Entity = $Entity
onready var _audio:AudioStreamPlayer3D = $AudioStreamPlayer3D

export var nameOverride:String = ""
export var active:bool = true

func _ready() -> void:
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.ENTS_GROUP_NAME)
	set_active(active)
	# _ent.triggerTargetName = triggerTargetName
	if nameOverride != "":
		_ent.selfName = nameOverride
	else:
		_ent.selfName = name
	var _err = _ent.connect("entity_restore_state", self, "restore_state")
	_err = _ent.connect("entity_append_state", self, "append_state")
	_err = _ent.connect("entity_trigger", self, "on_trigger")

func get_editor_info() -> Dictionary:
	visible = true
	var info:Dictionary = _ent.get_editor_info_base()
	info.scalable = true
	info.rotatable = true
	# var info = {
	# 	scalable = true,
	# 	rotatable = true,
	# 	fields = {}
	# }
	ZEEMain.create_field(info.fields, "sn", "Self Name", "text", _ent.selfName)
	ZEEMain.create_field(info.fields, "active", "Active", "bool", str(self.active))
	return info

func restore_from_editor(dict:Dictionary) -> void:
	_ent.restore_state(dict)

# returns true if field was set successfully
# func set_editor_field(_fieldName:String, _value) -> bool:
# 	return true

func set_active(flag:bool) -> void:
	active = flag
	_shape.disabled = !active
	if Main.is_in_editor():
		visible = true
	else:
		_mesh.visible = active
	_audio.play()

func append_state(_dict:Dictionary) -> void:
	_dict.active = active
	_dict.xform = ZqfUtils.transform_to_dict(self.global_transform)

func write_state() -> Dictionary:
	return {
		active = active
	}

func restore_state(data:Dictionary) -> void:
	set_active(ZqfUtils.safe_dict_b(data, "active", self.active))
	ZqfUtils.safe_dict_apply_transform(data, "xform", self)

# func on_trigger() -> void:
# 	set_active(!active)

func on_trigger(_msg:String, _params:Dictionary) -> void:
	if _msg == "on":
		set_active(true)
	elif _msg == "off":
		set_active(false)
	else:
		set_active(!active)

func ents_on_global_command(command:String) -> void:
	if command == Groups.ENTS_CMD_DISABLE_ALL_FORCEFIELDS:
		set_active(false)
	pass
