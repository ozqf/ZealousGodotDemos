extends Node

var on:bool = false
var _target:Control = null;
var _output:ColorRect = null;

func _ready() -> void:
	pass

func init(target:Control, output:ColorRect) -> void:
	_target = target
	_output = output
	_target.connect("mouse_entered", self, "_on_mouse_entered")
	_target.connect("mouse_exited", self, "_on_mouse_exited")
	pass

func _set_output_color(color:Color) -> void:
	if _output != null:
		_output.color = color

func _on_mouse_entered() -> void:
	on = true
	_set_output_color(Color(0.5, 0.5, 0.0, 0.2))

func _on_mouse_exited() -> void:
	on = false
	_set_output_color(Color(0.0, 0.0, 0.0, 0.2))
