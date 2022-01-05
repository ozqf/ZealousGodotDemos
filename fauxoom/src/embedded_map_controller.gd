extends Spatial

# var _prefab_player = preload("res://prefabs/player.tscn")
# var _prefab_mob_gunner = preload("res://prefabs/dynamic_entities/mob_gunner.tscn")
# var _prefab_horde_spawn = preload("res://prefabs/static_entities/horde_spawn.tscn")

onready var _camera:Camera = $Camera

# var _startEnts = []

# func _ready() -> void:
# 	add_to_group(Groups.GAME_GROUP_NAME)

# func game_on_player_spawned(_player) -> void:
# 	print("Embedded map control - player spawned")
# 	_camera.current = false

# func game_on_reset() -> void:
# 	_camera.current = true

# func game_on_level_completed() -> void:
# 	_camera.current = true

# func start_play() -> void:
# 	print("Embedded map start play")
# 	var l:int = _startEnts.size()
# 	for _i in range (0, l):
# 		var ent = _startEnts[_i]
# 		if ent.has_method("start_play"):
# 			ent.start_play($dynamic as Spatial)
