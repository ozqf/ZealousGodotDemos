extends Spatial

enum Mode { Recording, Playing, Paused }

var _mode = Mode.Playing
var _snapshots = []
var _ents = []
var _nextId:int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Snapshot init")

func register_entity(ent:Entity) -> int:
	_ents.push_back(ent)
	var id:int = _nextId
	_nextId += 1
	return id

func deregister_entity(_ent:Entity) -> void:
	var _i:int = _ents.find(_ent)
	_ents.remove(_i)
