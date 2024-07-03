extends Area2D
class_name HitSwitch

var _unpressedSprite = load("res://assets/sprites/switch_unpressed.png")
var _pressedSprite = load("res://assets/sprites/switch_pressed.png")

var _pressed:bool = false
var _tick:float = 0
var _resetTime:float = 2

@export var trigger_target:String = ""

func hit():
	if _pressed:
		return
	_pressed = true
	_tick = _resetTime
	$Sprite2D.texture = _pressedSprite
	if trigger_target != "":
		#print("Hit switch triggering " + trigger_target)
		get_tree().call_group("trigger_targets", "trigger", trigger_target)
	pass

func _process(_delta):
	if !_pressed:
		return
	_tick -= _delta
	if _tick <= 0:
		_pressed = false
		$Sprite2D.texture = _unpressedSprite
