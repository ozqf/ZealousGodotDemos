extends Node3D

@onready var _area:Area3D = $Area3D
@onready var _dest:Node3D = $destination

func _ready():
	_area.connect("body_entered", _on_body_entered)

func _on_body_entered(body:Node3D) -> void:
	if body.has_method("teleport"):
		body.teleport(_dest.global_transform)
		pass
	pass
