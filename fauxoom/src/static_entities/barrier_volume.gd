extends Spatial
class_name BarrierVolume

onready var _mesh:MeshInstance = $MeshInstance
onready var _shape:CollisionShape = $CollisionShape
onready var _ent:Entity = $Entity

export var triggerTargetName:String = ""
export var active:bool = true

var _spawnState:Dictionary = {}

func _ready() -> void:
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.ENTS_GROUP_NAME)
	set_active(active)
	_spawnState = write_state()
	_ent.triggerTargetName = triggerTargetName
	_ent.selfName = name
	var _err = _ent.connect("entity_restore_state", self, "restore_state")
	_err = _ent.connect("entity_append_state", self, "append_state")
	_err = _ent.connect("entity_trigger", self, "on_trigger")

func set_active(flag:bool) -> void:
	active = flag
	_shape.disabled = !active
	_mesh.visible = active

func append_state(_dict:Dictionary) -> void:
	_dict.active = active

func write_state() -> Dictionary:
	return {
		active = active
	}

func restore_state(data:Dictionary) -> void:
	set_active(data.active)

func game_on_reset() -> void:
	restore_state(_spawnState)

func on_trigger() -> void:
	print(name + " triggered")
	set_active(!active)
