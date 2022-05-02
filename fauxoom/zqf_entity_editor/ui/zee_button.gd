extends Button

signal clicked(buttonInstance)

func _ready() -> void:
	var _result = connect("button_down", self, "_on_click")
	pass

func _on_click() -> void:
	emit_signal("clicked", self)
	pass
