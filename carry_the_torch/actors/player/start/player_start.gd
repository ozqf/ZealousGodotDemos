extends Node3D

var _playerAvatarAttempt1 = preload("res://actors/player/player_avatar.tscn")
var _playerAvatarAttempt2 = preload("res://actors/player/avatar_type_b/player_avatar_type_b.tscn")
var _playerAvatarRoller1 = preload("res://actors/player/avatar_type_roller/player_avatar_roller.tscn")
var _playerAvatarWheel1 = preload("res://actors/player/avatar_wheel_1/player_avatar_wheel_1.tscn")

var _currentAvatar:Node3D = null

@onready var _ui:Control = $ui

func _spawn_prefab(prefab, positionOffset:Vector3) -> void:
	_currentAvatar = prefab.instantiate()
	self.get_parent().add_child(_currentAvatar)
	var t:Transform3D = self.global_transform
	t.origin += positionOffset
	_currentAvatar.global_transform = t
	_ui.visible = false

func _physics_process(_delta: float) -> void:
	if _currentAvatar != null:
		if Input.is_action_just_pressed("reset"):
			_currentAvatar.queue_free()
			_currentAvatar = null
			_ui.visible = true
		return
	if Input.is_action_just_pressed("slot_1"):
		_spawn_prefab(_playerAvatarAttempt1, Vector3(0, 0.5, 0))
	elif Input.is_action_just_pressed("slot_2"):
		_spawn_prefab(_playerAvatarAttempt2, Vector3(0, 0.5, 0))
	elif Input.is_action_just_pressed("slot_3"):
		_spawn_prefab(_playerAvatarRoller1, Vector3(0, 0.5, 0))
	elif Input.is_action_just_pressed("slot_4"):
		_spawn_prefab(_playerAvatarWheel1, Vector3(0, 0.5, 0))
