extends Node

var _worldType:PackedScene = preload("res://worlds/sandbox/sandbox.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("_spawn_world")

func _spawn_world() -> void:
	Zqf.create_new_world(_worldType)
	pass
