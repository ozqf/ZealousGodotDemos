extends Node3D

var _bikePrefab:PackedScene = preload("res://test_10_highway/prefabs/player_bike_1.tscn")


@onready var _startBike:Node3D = $start_bike

func _ready() -> void:
	pass

func _spawn_bike() -> void:
	var bike:Node3D = _bikePrefab.instantiate() as Node3D
	bike.global_transform = _startBike.global_transform
	add_child(bike)
