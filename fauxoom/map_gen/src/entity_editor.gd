extends Spatial
class_name EntityEditor

const _prefab_spawn = preload("res://map_gen/prefabs/spawn_point.tscn")
const _mapSpawnDef_t = preload("./map_spawn_def.gd")

onready var _entTypeLabel:Label = $ui/template_list/ent_type_label

var _mapDef:MapDef = null

func _ready() -> void:
	_entTypeLabel.text = "Create:\nPlayerStart"

func set_map_def(newMapDef:MapDef) -> void:
	_mapDef = newMapDef
