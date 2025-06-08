extends Label3D

func _physics_process(_delta: float) -> void:
	self.text = get_parent().get_debug_text()
