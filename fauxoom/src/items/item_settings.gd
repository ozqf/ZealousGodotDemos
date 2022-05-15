extends Spatial

export var selfName:String = ""
export var triggerTargetName:String = ""
# respawn flag allows an item to be respawned via triggers, rather than on its own timer
export var respawns:bool = false
# timer for self respawn
export var selfRespawnTime:float = 20
# emit gfx to draw attention to this item
export var isImportant:bool = false

onready var _ent:Entity = $Entity

func _ready() -> void:
	_refresh_settings()

func _refresh_settings() -> void:
	if selfRespawnTime > 0.0:
		respawns = true
	$item_base.set_settings(respawns, selfRespawnTime, isImportant)
	_ent.selfName = selfName
	_ent.triggerTargetName = triggerTargetName

func get_editor_info() -> Dictionary:
	# visible = true
	return {
		prefab = _ent.prefabName,
		fields = [
			{ name: "selfName", value="", type="text" },
			{ name: "targets", value="", type="text" },
			{ name: "respawnTime", value=20.0, type="float" },
			{ name: "respawns", value=false, type="flag" },
			{ name: "isImportant", value=false, type="flag" }
		]
	}

func refresh_editor_fields(_dict:Dictionary) -> void:
	selfName = String(_dict.selfName)
	triggerTargetName = String(_dict.targets)
	respawns = bool(_dict.respawns)
	selfRespawnTime = float(_dict.respawnTime)
	isImportant = bool(_dict.isImportant)
	_refresh_settings()
