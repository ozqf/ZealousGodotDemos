extends Camera3D

@onready var _ent:Entity = $Entity

func _ready() -> void:
	var _r = _ent.connect("entity_append_state", self, "append_state")
	_r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_trigger", self, "on_trigger")
	add_to_group(Groups.GAME_GROUP_NAME)

func append_state(_dict:Dictionary) -> void:
	_dict.current = current

func restore_state(_dict:Dictionary) -> void:
	current = _dict.current

# force off on player spawn
func game_on_player_spawned(_player) -> void:
	current = false
