extends KinematicBody2D

onready var _left:WorldSensor = $left
onready var _right:WorldSensor = $right

export var speed:int = 64

var _velocity:Vector2 = Vector2(-64, 0)

func _ready():
	_velocity = Vector2(speed, 0)

func _physics_process(_delta):
	if _velocity.x < 0:
		if _left.on():
			_velocity.x = -_velocity.x
			print("Turn right")
	if _velocity.x > 0:
		if _right.on():
			_velocity.x = -_velocity.x
			print("Turn left")
	position += _velocity * _delta
	# move_and_slide(_velocity)
