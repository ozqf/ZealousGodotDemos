extends Node3D

func _ready():
	self.visible = false
	add_to_group(Game.GROUP_PLAYER_STARTS)
	#call_deferred("spawn_player")

func spawn_player() -> void:
	Game.spawn_player(self.global_position, self.rotation_degrees.y)
