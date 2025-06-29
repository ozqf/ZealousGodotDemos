extends Node3D

var _playerAvatarAttempt1 = preload("res://actors/player/player_avatar.tscn")
var _playerAvatarAttempt2 = preload("res://actors/player/avatar_type_b/player_avatar_type_b.tscn")
var _playerAvatarRoller1 = preload("res://actors/player/avatar_type_roller/player_avatar_roller.tscn")
var _playerAvatarWheel1 = preload("res://actors/player/avatar_wheel_1/player_avatar_wheel_1.tscn")

var _currentAvatar:Node3D = null

@onready var _ui:Control = $ui

func _spawn_prefab(prefab) -> void:
	_currentAvatar = prefab.instantiate()
	self.get_parent().add_child(_currentAvatar)
	var t:Transform3D = self.global_transform
	t.origin.y += 0.5
	_currentAvatar.global_transform = t
	self.queue_free()

func _physics_process(_delta: float) -> void:
	if _currentAvatar != null:
		return
	if Input.is_action_just_pressed("slot_1"):
		_currentAvatar = _playerAvatarAttempt1.instantiate()
		self.get_parent().add_child(_currentAvatar)
		var t:Transform3D = self.global_transform
		t.origin.y += 0.5
		_currentAvatar.global_transform = t
		self.queue_free()
	elif Input.is_action_just_pressed("slot_2"):
		_currentAvatar = _playerAvatarAttempt2.instantiate()
		self.get_parent().add_child(_currentAvatar)
		var t:Transform3D = self.global_transform
		t.origin.y += 0.5
		_currentAvatar.global_transform = t
		self.queue_free()
	elif Input.is_action_just_pressed("slot_3"):
		_spawn_prefab(_playerAvatarRoller1)
	elif Input.is_action_just_pressed("slot_4"):
		_spawn_prefab(_playerAvatarWheel1)
