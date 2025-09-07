extends Node3D

var _bikePrefab:PackedScene = preload("res://test_10_highway/prefabs/player_bike_1.tscn")
var _ropeHangPrefab:PackedScene = preload("res://test_10_highway/prefabs/player_rope_hang.tscn")

@onready var _startBike:Node3D = $start_bike

var _player:Node3D = null

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("slot_1"):
		_spawn_bike()
	elif Input.is_action_just_pressed("slot_2"):
		_spawn_rope_hang()

func _spawn_rope_hang() -> void:
	var root:Node3D = get_tree().get_first_node_in_group("hang_point")
	if root == null:
		return
	
	if _player != null:
		_player.queue_free()
		_player = null
	_player = _ropeHangPrefab.instantiate() as Node3D
	add_child(_player)
	_player.spawn(root, -3)

func _spawn_bike() -> void:
	if _player != null:
		_player.queue_free()
		_player = null
	_player = _bikePrefab.instantiate() as Node3D
	_player.global_transform = _startBike.global_transform
	add_child(_player)
