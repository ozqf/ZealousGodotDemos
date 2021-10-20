extends Spatial

onready var _ent:Entity = $Entity

# Called when the node enters the scene tree for the first time.
func _ready():
	_ent.selfName = name
	visible = false
