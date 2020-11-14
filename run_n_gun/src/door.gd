extends KinematicBody2D
class_name Door

var _openSprite = load("res://assets/sprites/door_open.png")
var _closedSprite = load("res://assets/sprites/door_closed.png")

var _closed:bool = true
var _pendingClosed:bool = true

func OpenDoor():
	_pendingClosed = false
	
func CloseDoor():
	_pendingClosed = true

func _process(delta):
	if _closed != _pendingClosed:
		_closed = _pendingClosed
		if _closed:
			$Sprite.texture = _closedSprite
			$CollisionShape2D.disabled = false
		else:
			$Sprite.texture = _openSprite
			$CollisionShape2D.disabled = true
	pass
