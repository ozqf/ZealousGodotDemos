extends Spatial
class_name KingTower

onready var _ent:Entity = $Entity

export var nodesCSV:String = ""

var _nodeIndex:int = -1
var _nodeNames = []

func _find_nodes(csv) -> void:
	_nodeNames = csv.split(",")
	for nodeName in _nodeNames:
		var ent = Ents.find_dynamic_entity_by_name(nodeName)

func append_state(_dict:Dictionary) -> void:
	_dict.xform = ZqfUtils.transform_to_dict(self.global_transform)
	_dict.nlist = nodesCSV

func restore_state(_dict:Dictionary) -> void:
	ZqfUtils.safe_dict_apply_transform(_dict, "xform", self)
	nodesCSV = ZqfUtils.safe_dict_s(_dict, "nlist", nodesCSV)

func get_editor_info() -> Dictionary:
	visible = true
	var data = {
		scalable = true,
		rotatable = true,
		fields = {
			nodesCSV = { name = "nodesCSV", type = "text", "value": nodesCSV }
		}
	}
	return data

func _process(_delta) -> void:
	pass
