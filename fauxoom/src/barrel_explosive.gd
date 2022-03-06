extends KinematicBody

onready var _ent:Entity = $Entity

func _ready():
	_ent.connect("entity_append_state", self, "append_state")
	_ent.connect("entity_restore_state", self, "restore_state")
	pass # Replace with function body.

func append_state(_dict:Dictionary) -> void:
	_dict.pos = ZqfUtils.v3_to_dict(global_transform.origin)

func restore_state(_dict:Dictionary) -> void:
	global_transform.origin = ZqfUtils.v3_from_dict(_dict.pos)

func use() -> void:
	print("Barrel - use!")

func hit(_hitInfo:HitInfo) -> int:
	print("Barrel - hit for " + str(_hitInfo.damage))
	return Interactions.HIT_RESPONSE_NONE
