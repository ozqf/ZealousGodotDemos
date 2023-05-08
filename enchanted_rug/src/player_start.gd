extends Spatial

var _playerFloatingType = preload("res://prefabs/player.tscn")

var _hasSpawned:bool = false

func _spawn(typeObj) -> void:
	_hasSpawned = true
	var plyr = _playerFloatingType.instance()
	add_child(plyr)
	plyr.global_transform = self.global_transform

func _process(_delta:float) -> void:
	if _hasSpawned:
		return
	if Input.is_action_just_pressed("slot_1"):
		_spawn(_playerFloatingType)

