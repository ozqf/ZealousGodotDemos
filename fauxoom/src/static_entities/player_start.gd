extends Spatial

var _player_t = preload("res://prefabs/player.tscn")

func _ready() -> void:
	add_to_group("entities")

func start_play(dynamicParentNode:Spatial) -> void:
	var player = _player_t.instance()
	dynamicParentNode.add_child(player)
	player.global_transform = self.global_transform

