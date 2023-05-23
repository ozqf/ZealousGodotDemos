extends Node3D

const MAX_LIVE_MOBS:int = 20

var _bouncerType = preload("res://actors/mobs/bouncer/mob_bouncer.tscn")

@onready var _timer:Timer = $spawn_timer

var _liveMobs:int = 0

func _ready():
	print("Created spawner")
	_timer.connect("timeout", _on_timeout)
	_timer.one_shot = true
	_timer.start()

func _on_timeout() -> void:
	_timer.start()
	if _liveMobs >= MAX_LIVE_MOBS:
		return
#	print("Spawn!")
	for _i in range(0, 1):
		_liveMobs += 1
		var mob:Node3D = Game.add_actor_scene(_bouncerType, self.global_transform)
		mob.connect("tree_exited", _on_mob_exited_tree)
		mob.launch()

func _on_mob_exited_tree() -> void:
	_liveMobs -= 1

func _process(delta):
	pass
