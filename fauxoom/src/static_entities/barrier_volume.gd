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

func set_active(flag:bool) -> void:
	active = flag
	_shape.disabled = !active
	_mesh.visible = active
	_audio.play()

func append_state(_dict:Dictionary) -> void:
	_dict.active = active

func write_state() -> Dictionary:
	return {
		active = active
	}

func restore_state(data:Dictionary) -> void:
	set_active(data.active)

# func on_trigger() -> void:
# 	set_active(!active)

func on_trigger(_msg:String, _params:Dictionary) -> void:
	set_active(!active)
