extends Control

onready var _nameInput:LineEdit = $ColorRect/VBoxContainer/name_input
onready var _targetsInput:LineEdit = $ColorRect/VBoxContainer/targets_input

func _ready():
	var _r = _nameInput.connect("text_changed", self, "_on_text_changed")
	_r = _targetsInput.connect("text_changed", self, "_on_targets_changed")
	pass

func _on_name_changed(txt:String) -> void:
	pass

func _on_targets_changed(txt:String) -> void:
	pass
