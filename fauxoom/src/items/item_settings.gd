extends Spatial

export var selfName:String = ""
export var triggerTargetName:String = ""
export var respawns:bool = false
export var selfRespawnTime:float = 20

onready var _ent:Entity = $Entity

func _ready() -> void:
	$item_base.set_settings(self)
	_ent.selfName = selfName
	_ent.triggerTargetName = triggerTargetName
