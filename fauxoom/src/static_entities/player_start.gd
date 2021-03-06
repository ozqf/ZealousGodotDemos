extends Spatial

var _player_t = preload("res://prefabs/player.tscn")

enum InventoryState {
	Resume,
	None,
	All
}

export var delaySpawn:bool = false
export(InventoryState) var inventoryState = InventoryState.Resume

func _ready() -> void:
	visible = false
	add_to_group(Groups.ENTS_GROUP_NAME)
	Game.register_player_start(self)
	add_to_group(Groups.GAME_GROUP_NAME)

func game_on_reset() -> void:
	print("Player start saw game reset")

func game_run_map_spawns() -> void:
	print("Player start - run map spawns")
	if !delaySpawn:
		start_play(Game.get_dynamic_parent())

func _exit_tree() -> void:
	Game.deregister_player_start(self)

func start_play(_dynamicParentNode:Spatial) -> void:
	print("Player start - play")
	var def = Ents.get_prefab_def(Entities.PREFAB_PLAYER)
	var player = def.prefab.instance()
	_dynamicParentNode.add_child(player)
	player.spawn(self.global_transform)
	if inventoryState == InventoryState.All:
		player.give_all()
