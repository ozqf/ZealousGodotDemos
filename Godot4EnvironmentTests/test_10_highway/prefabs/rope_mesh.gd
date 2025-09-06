extends Node3D

@onready var _rope:Node3D = $rope
@onready var _player:Node3D = $player

func _process(_delta:float) -> void:
	_rope.look_at(_player.global_position, Vector3.BACK)
