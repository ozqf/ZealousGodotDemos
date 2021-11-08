extends Spatial

onready var _ent:Entity = $Entity

export var targetName:String = ""
export var triggerTargetName:String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	if targetName != "":
		_ent.selfName = targetName
	else:
		_ent.selfName = name
	visible = false
