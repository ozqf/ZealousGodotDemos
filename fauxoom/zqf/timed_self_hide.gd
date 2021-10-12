extends Spatial

export var time:float = 0.1
export var hide_parent:bool = false

func show_for_time(newTime:float) -> void:
	time = newTime
	if hide_parent:
		var parent = get_parent()
		if parent is Spatial:
			parent.show()
	else:
		self.show()

func _process(_delta:float):
	time -= _delta
	if time <= 0:
		time = 99999999
		if hide_parent:
			var parent = get_parent()
			if parent is Spatial:
				parent.hide()
		else:
			self.hide()
