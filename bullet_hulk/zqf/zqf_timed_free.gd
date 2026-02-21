extends Node3D

@export var seconds:float = 2.0

func _physics_process(delta: float) -> void:
	seconds -= delta
	if seconds <= 0.0:
		self.queue_free()
