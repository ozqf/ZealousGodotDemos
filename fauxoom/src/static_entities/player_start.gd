extends Spatial

var _player_t = preload("res://prefabs/player.tscn")

func _ready() -> void:
	add_to_group(Groups.ENTS_GROUP_NAME)
	Game.register_player_start(self)
	add_to_group(Groups.GAME_GROUP_NAME)

func game_on_reset() -> void:
	print("Player start saw game reset")

func _exit_tree() -> void:
	Game.deregister_player_start(self)

func start_play(dynamicParentNode:Spatial) -> void:
	var player = _player_t.instance()
	dynamicParentNode.add_child(player)
	player.global_transform = self.global_transform
