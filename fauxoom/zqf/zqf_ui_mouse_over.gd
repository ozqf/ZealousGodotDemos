extends Control

var mouseOver:bool = false

func _ready():
	var _result = connect("mouse_entered", self, "_mouse_enter")
	_result = connect("mouse_exited", self, "_mouse_exit")
	pass # Replace with function body.

func _mouse_enter() -> void:
	mouseOver = true

func _mouse_exit() -> void:
	mouseOver = false
