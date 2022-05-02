extends Spatial

const Enums = preload("res://src/enums.gd")

onready var _ent:Entity = $Entity

enum InventoryState {
	Resume,
	None,
	All
}

export var delaySpawn:bool = true
export(InventoryState) var inventoryState = InventoryState.Resume

var _hasSpawned:bool = false

func _ready() -> void:
	visible = false
	add_to_group(Groups.ENTS_GROUP_NAME)
	Game.register_player_start(self)
	add_to_group(Groups.GAME_GROUP_NAME)
	var _r = _ent.connect("entity_append_state", self, "append_state")
	_r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_trigger", self, "on_trigger")

func append_state(_dict:Dictionary) -> void:
	_dict.hasSpawned = _hasSpawned

func restore_state(_dict:Dictionary) -> void:
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
	var def = Ents.get_prefab_def(Entities.PREFAB_PLAYER)
	var player = def.prefab.instance()
	_dynamicParentNode.add_child(player)
	player.spawn(self.global_transform)
	if inventoryState == InventoryState.All:
		player.give_all()

func _process(_delta:float) -> void:
	if !_hasSpawned && Game.get_game_mode() == Enums.GameMode.Classic && Input.is_action_just_pressed("ui_select"):
		start_play(Game.get_dynamic_parent())
