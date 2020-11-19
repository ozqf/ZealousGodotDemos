extends Area2D
class_name HitSwitch

var _unpressedSprite = load("res://assets/sprites/switch_unpressed.png")
var _pressedSprite = load("res://assets/sprites/switch_pressed.png")

var _pressed:bool = false
var _tick:float = 0
var _resetTime:float = 2

func hit():
	if _pressed:
		return
	_pressed = true
	_tick = _resetTime
	$Sprite.texture = _pressedSprite
	pass

func _process(_delta):
	if !_pressed:
		return
	_tick -= _delta
	if _tick <= 0:
		_pressed = false
		$Sprite.texture = _unpressedSprite
