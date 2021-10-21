extends Node2D

var _gruntPrefab = preload("res://prefabs/grunt.tscn")
signal spawner_empty

var _capacity:int = 6
var _maxLiveMobs:int = 1
var _liveMobs:int = 0
var _tick:float = 0
var _spawnDelay:float = 1.0
var _active:bool = true

func _mob_died():
	_liveMobs -= 1

func _kill_self():
	_active = false
	emit_signal("spawner_empty")
	queue_free()

func _spawn_mob():
	var mob = _gruntPrefab.instance()
	Game.get_current_scene_root().add_child(mob)
	mob.position = position
	mob.connect("enemy_died", self, "_mob_died")
	_liveMobs += 1
	_capacity -= 1

func _process(delta):
	if !_active:
		return
	if _liveMobs >= _maxLiveMobs:
		return
	if _capacity <= 0:
		if _liveMobs <= 0:
			_kill_self()
		return
	_tick -= delta
	if _tick <= 0:
		_tick = _spawnDelay
		_spawn_mob()
