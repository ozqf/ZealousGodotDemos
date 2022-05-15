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
	$item_base.set_settings(respawns, selfRespawnTime, isImportant)
	_ent.selfName = selfName
	_ent.triggerTargetName = triggerTargetName

func set_enable(_flag:bool) -> void:
	pass

func get_editor_info() -> Dictionary:
	# visible = true
	return {
		prefab = _ent.prefabName,
		fields = {
			selfName = { "name": "selfName", "value":_ent.selfName, "type": "text" },
			targets = { "name": "targets", "value":_ent.triggerTargetName, "type": "text" },
			respawnTime = { "name": "respawnTime", "value":selfRespawnTime, "type": "float" },
			respawns = { "name": "respawns", "value":respawns, "type": "flag" },
			isImportant = { "name": "isImportant", "value":isImportant, "type": "flag" }
		}
	}

func refresh_editor_info(data:Dictionary) -> void:
	var fields = data.fields
	print("Item settings - refresh fields")
	selfName = String(fields.selfName.value)
	triggerTargetName = String(fields.targets.value)
	respawns = ZqfUtils.parse_bool(fields.respawns.value)
	selfRespawnTime = float(fields.respawnTime.value)
	isImportant = ZqfUtils.parse_bool(fields.isImportant.value)
	_refresh_settings()
