extends Label

func _process(_delta) -> void:
	self.text = str(Engine.get_frames_per_second()) + "fps"
