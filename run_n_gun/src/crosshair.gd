extends Node2D

func _process(delta):
	var mPos := get_viewport().get_mouse_position()
	set_global_position(mPos)
	Game.cursorPos = mPos
