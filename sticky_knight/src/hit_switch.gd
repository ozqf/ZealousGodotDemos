extends Area2D
class_name HitSwitch

var _unpressedSprite = load("res://assets/sprites/switch_unpressed.png")
var _pressedSprite = load("res://assets/sprites/switch_pressed.png")

var _pressed:bool = false

func hit():
	if _pressed:
		return
	_pressed = true
	$Sprite.texture = _pressedSprite
	pass
