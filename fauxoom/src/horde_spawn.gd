extends Spatial

var _prefab_mob_gunner = preload("res://prefabs/entities/mob_gunner.tscn")

var _childType:int = 1

var _maxMobs:int = 4
var _maxLiveMobs:int = 2
var _liveMobs:int = 0
var _deadMobs:int = 0

var _tickMax:float = 2
var _tick:float = 0


func _ready() -> void:
	print("Horde spawn ready")

func _process(_delta:float) -> void:
	var consumed = _deadMobs + _liveMobs
	if (_liveMobs < _maxLiveMobs) && (consumed < _maxMobs):
		_tick -= _delta
		if _tick <= 0:
			_tick = _tickMax
			_liveMobs += 1
			_spawn_child()

func _spawn_child() -> void:
	var mob = _prefab_mob_gunner.instance()
	get_parent().add_child(mob)
	mob.global_transform = self.global_transform
	mob.connect("on_mob_died", self, "_on_mob_died")

func _on_mob_died(_mob) -> void:
	_liveMobs -= 1
	_deadMobs += 1
	print("Mob death: " + str(_deadMobs) + " dead vs " + str(_maxMobs) + " max")
	if _deadMobs >= _maxMobs:
		print("Horde spawn - all children dead")
