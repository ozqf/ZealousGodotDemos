# This class exists to feed settings applied in the godot inspector to an item_base
# it contains no logic itself
extends Spatial

export var selfName:String = ""
export var triggerTargetName:String = ""
# respawn flag allows an item to be respawned via triggers, rather than on its own timer
export var respawns:bool = false
# timer for self respawn
export var selfRespawnTime:float = 20
# emit gfx to draw attention to this item
export var isImportant:bool = false

onready var _item:ItemBase = $item_base
onready var _ent:Entity = $Entity

func _ready() -> void:
	_refresh_settings()

func _refresh_settings() -> void:
	_item.set_settings(respawns, selfRespawnTime, isImportant)
	_ent.selfName = selfName
	_ent.triggerTargetName = triggerTargetName

func set_enable(_flag:bool) -> void:
	pass

func get_editor_info() -> Dictionary:
	return _item.get_editor_info()

func restore_from_editor(dict:Dictionary) -> void:
	_ent.restore_state(dict)

func set_velocity(newVelocity:Vector3) -> void:
	_item.set_velocity(newVelocity)

func set_time_to_live(seconds:float) -> void:
	_item.set_time_to_live(seconds)
