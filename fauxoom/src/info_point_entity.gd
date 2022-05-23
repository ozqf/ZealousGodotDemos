extends Spatial

onready var _ent:Entity = $Entity

export var targetName:String = ""
export var triggerTargetName:String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	var _result = _ent.connect("entity_append_state", self, "append_state")
	_result = _ent.connect("entity_restore_state", self, "restore_state")
	if targetName != "":
		_ent.selfName = targetName
	else:
		_ent.selfName = name
	if Main.is_in_game():
		visible = false

func append_state(_dict:Dictionary) -> void:
	_dict.xform = ZqfUtils.transform_to_dict(global_transform)
	pass

func restore_state(data:Dictionary) -> void:
	ZqfUtils.safe_dict_apply_transform(data, "xform", self)
	pass
