extends Node3D

@export var hideOnStart:bool = true

func _ready():
	visible = !hideOnStart
