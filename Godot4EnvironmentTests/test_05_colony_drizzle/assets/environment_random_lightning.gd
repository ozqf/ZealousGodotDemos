extends Node

@onready var _animPlayer:AnimationPlayer = $AnimationPlayer
@onready var _timer:Timer = $Timer

func _ready() -> void:
	_timer.connect("timeout", _timeout)
	_timer.start(randf_range(6, 20))

func _timeout() -> void:
	self.global_position.x = randf_range(-100, 100)
	self.global_position.z = randf_range(-100, 100)
	_timer.start(randf_range(2, 10))
	_animPlayer.play("flash")
