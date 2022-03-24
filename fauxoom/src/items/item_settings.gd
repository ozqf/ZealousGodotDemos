extends Spatial

export var selfName:String = ""
export var triggerTargetName:String = ""
export var respawns:bool = false
export var selfRespawnTime:float = 20
export var isImportant:bool = false

onready var _ent:Entity = $Entity

func _ready() -> void:
	$item_base.set_settings(self)
	$item_base.set_important_flag(isImportant) 
	_ent.selfName = selfName
	_ent.triggerTargetName = triggerTargetName
	
