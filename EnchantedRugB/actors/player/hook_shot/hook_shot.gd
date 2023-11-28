extends Node3D
class_name HookShot

var _isAttached:bool = false

func is_attached() -> bool:
	return _isAttached

func attach(pos:Vector3) -> void:
	_isAttached = true
	self.global_position = pos
	self.visible = true

func release() -> void:
	_isAttached = false
	self.visible = false

func update_input(_input:PlayerInput) -> void:
	_input.hooked = _isAttached
	_input.hookPosition = self.global_position
	pass
