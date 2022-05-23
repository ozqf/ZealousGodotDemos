extends Spatial

const Enums = preload("res://src/enums.gd")

enum InventoryState {
	Resume,
	None,
	All
}

export var delaySpawn:bool = true
export(InventoryState) var inventoryState = InventoryState.Resume

onready var _ent:Entity = $Entity
var _hasSpawned:bool = false

func _ready() -> void:
	visible = false
	add_to_group(Groups.ENTS_GROUP_NAME)
	Game.register_player_start(self)
	add_to_group(Groups.GAME_GROUP_NAME)
	var _r = _ent.connect("entity_append_state", self, "append_state")
	_r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_trigger", self, "on_trigger")

func get_editor_info() -> Dictionary:
	visible = true
	return {}

func append_state(_dict:Dictionary) -> void:
	_dict.xform = ZqfUtils.transform_to_dict(global_transform)
	_dict.hasSpawned = _hasSpawned

func restore_state(_dict:Dictionary) -> void:
	global_transform = ZqfUtils.transform_from_dict(_dict.xform)
	_hasSpawned = _dict.hasSpawned

func game_on_reset() -> void:
	print("Player start saw game reset")

func game_run_map_spawns() -> void:
	print("Player start - run map spawns")
	_hasSpawned = false
	if !delaySpawn:
		start_play(Game.get_dynamic_parent())

func _exit_tree() -> void:
	Game.deregister_player_start(self)

func start_play(_dynamicParentNode:Spatial) -> void:
	print("Player start - play")
	_hasSpawned = true
	#var def = Ents.get_prefab_def(Entities.PREFAB_PLAYER)
	var def = Ents.get_prefab_def("player")
	var player = def.prefab.instance()
	_dynamicParentNode.add_child(player)
	player.spawn(self.global_transform)
	if inventoryState == InventoryState.All:
		player.give_all()

func _process(_delta:float) -> void:
	var inGame:bool = Main.get_app_state() == Enums.AppState.Game
	if !_hasSpawned && inGame && Input.is_action_just_pressed("ui_select"):
		start_play(Game.get_dynamic_parent())
