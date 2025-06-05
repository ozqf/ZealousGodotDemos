extends Node
class_name ZqfTimedCull

@export var tick:float = 2.0
@export var cullParent:bool = false
@export var tickRandomOffset:float = 0.0

func _ready() -> void:
	if tickRandomOffset != 0.0:
		var val:float = randf_range(-tickRandomOffset, tickRandomOffset)
		tick += val

func _process(delta):
	tick -= delta
	if tick <= 0.0:
		tick = 9999999
		if cullParent:
			self.get_parent().queue_free()
		else:
			self.queue_free()
