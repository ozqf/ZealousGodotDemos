extends Node
class_name SpawnQueue

const Enums = preload("res://src/enums.gd")

var _def_t = preload("res://src/defs/spawn_def.gd")

var _spawnPointEnts = null
var _totalSpawns:int = 0
var _spawnedCount:int = 0
var _difficulty:int = 0
var _waveCount:int = 0

var _killed:int = 0

func build(count:int, difficulty:int, spawnPointEnts) -> void:
	_totalSpawns = count
	_difficulty = difficulty
	_spawnPointEnts = spawnPointEnts
	_killed = 0
	_spawnedCount = 0
	pass

func _pick_spawn_point() -> Transform:
	var numPoints:int = _spawnPointEnts.size()
	if numPoints == 0:
		return get_parent().global_transform
	var i:int = int(rand_range(0, numPoints))
	var ent:Entity = _spawnPointEnts[i]
	return ent.get_ent_transform()

func _pick_enemy_hard() -> int:
	var r:float = randf()
	if r > 0.95:
		return Enums.EnemyType.Golem
	elif r > 0.85:
		return Enums.EnemyType.Spider
	elif r > 0.7:
		return Enums.EnemyType.Cyclops
	elif r > 0.5:
		return Enums.EnemyType.FleshWorm
	else:
		return Enums.EnemyType.Punk

func _pick_enemy_medium() -> int:
	var r:float = randf()
	if r > 0.8:
		return Enums.EnemyType.Spider
	elif r > 0.6:
		return Enums.EnemyType.Cyclops
	elif r > 0.5:
		return Enums.EnemyType.FleshWorm
	else:
		return Enums.EnemyType.Punk

func _pick_enemy_easy() -> int:
	var r:float = randf()
	if r > 0.7:
		return Enums.EnemyType.FleshWorm
	else:
		return Enums.EnemyType.Punk

func _get_next_enemy_type(difficulty:int) -> int:
	if difficulty < 1:
		return _pick_enemy_easy()
	elif difficulty < 2:
		return _pick_enemy_medium()
	return _pick_enemy_hard()

func get_next() -> SpawnDef:
	var spawn = _def_t.new()
	spawn.t = _pick_spawn_point()
	spawn.type = Ents.select_prefab(_get_next_enemy_type(_difficulty))
	return spawn
