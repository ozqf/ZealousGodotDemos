extends Node3D

var _bouncerType = preload("res://actors/mobs/bouncer/mob_bouncer.tscn")

@onready var _timer:Timer = $spawn_timer

func _ready():
	print("Created spawner")
	_timer.connect("timeout", _on_timeout)
	_timer.one_shot = true
	_timer.start()

func _on_timeout() -> void:
	print("Spawn!")
	for _i in range(0, 20):
		var mob = Game.add_actor_scene(_bouncerType, self.global_transform)
		mob.launch()

func _process(delta):
	pass
