extends Node
class_name MenuMain

onready var _gui:Control = $gui

func _ready():
	var _foo = $gui/root/level_01.connect("pressed", self, "on_level_01")	
	_foo = $gui/root/level_02.connect("pressed", self, "on_level_02")
	_foo = $gui/root/level_test.connect("pressed", self, "on_level_test")
	_foo = $gui/root/editor.connect("pressed", self, "on_editor")
	_foo = $gui/root/exit.connect("pressed", self, "on_exit")
	_gui.visible = false

func on_level_01():
	var _foo = get_tree().change_scene("res://levels/level_01.tscn")
	_gui.visible = false

func on_level_02():
	#_gui.visible = false
	pass

func on_level_test():
	var _foo = get_tree().change_scene("res://levels/level_test.tscn")
	_gui.visible = false

func on_editor():
	var _foo = get_tree().change_scene("res://levels/editor.tscn")
	_gui.visible = false

func on_exit():
	get_tree().quit()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		_gui.visible = !_gui.visible
	pass
