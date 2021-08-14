extends Area

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(_body) -> void:
	if _body.has_method("void_volume_touch"):
		_body.void_volume_touch()
