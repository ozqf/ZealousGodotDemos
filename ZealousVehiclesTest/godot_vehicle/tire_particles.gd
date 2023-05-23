extends Node3D

@export var timeToLive:float = 10.0

func _physics_process(delta):
	timeToLive -= delta
	if timeToLive <= 0.0:
		timeToLive = 999
		self.queue_free()
