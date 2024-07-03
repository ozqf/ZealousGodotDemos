extends CharacterBody2D

var offset:Vector2 = Vector2()
@onready var _sprite:Sprite2D = $Sprite2D
@onready var _shape:CollisionShape2D = $CollisionShape2D

func on():
	_sprite.visible = true
	_shape.disabled = false
	pass

func off():
	_sprite.visible = false
	_shape.disabled = true
