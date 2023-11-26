extends Node3D

@onready var _bodyShape:CollisionShape3D = $CollisionShape3D

func activate() -> void:
	_bodyShape.disabled = false
	self.visible = true

func deactivate() -> void:
	_bodyShape.disabled = true
	self.visible = false

func input_physics_process(_input:PlayerInput, _delta:float) -> void:
	pass
