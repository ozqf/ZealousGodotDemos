extends Node2D

func _process(_delta):
	var mPos := get_viewport().get_mouse_position()
	set_global_position(mPos)
	Game.cursorPos = mPos
