extends Node

export var time:float = 0.1
export var remove_parent:bool = false

func _process(_delta:float):
	time -= _delta
	if time <= 0:
		time = 99999999
		if remove_parent:
			get_parent().queue_free()
		else:
			self.queue_free()
