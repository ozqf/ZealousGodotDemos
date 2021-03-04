extends Spatial

var _prefab_mob_gunner = preload("res://prefabs/dynamic_entities/mob_gunner.tscn")

export var triggerName:String = ""
export var triggerTargetName:String = ""

export var childType:int = 1
export var tickMax:float = 2
export var maxMobs:int = 4
export var maxLiveMobs:int = 2

var _liveMobs:int = 0
var _deadMobs:int = 0

var _tick:float = 0

var _active:bool = false

var _spawnState:Dictionary

func _ready() -> void:
	print("Horde spawn ready")
	add_to_group(Groups.ENTS_GROUP_NAME)
	add_to_group(Groups.GAME_GROUP_NAME)
	_spawnState = write_state()

func write_state() -> Dictionary:
	return {
		liveMobs = _liveMobs,
		deadMobs = _deadMobs,
		tick = _tick,
		active = _active
	}

func restore_state(data:Dictionary) -> void:
	_liveMobs = data.liveMobs
	_deadMobs = data.deadMobs
	_tick = data.tick
	_active = data.active

func game_on_reset() -> void:
	print("Horde spawn saw game reset")
	restore_state(_spawnState)

func _process(_delta:float) -> void:
	if !_active:
		return
	var consumed = _deadMobs + _liveMobs
	if (_liveMobs < maxLiveMobs) && (consumed < maxMobs):
		_tick -= _delta
		if _tick <= 0:
			_tick = tickMax
			_liveMobs += 1
			_spawn_child()

func on_trigger_entities(name:String) -> void:
	print("Horde spawn saw trigger name " + name + " vs self name " + triggerName)
	if name == "":
		return
	if name == triggerName:
		_active = !_active

func _spawn_child() -> void:
	var mob = _prefab_mob_gunner.instance()
	get_parent().add_child(mob)
	mob.global_transform = self.global_transform
	mob.connect("on_mob_died", self, "_on_mob_died")

func _on_mob_died(_mob) -> void:
	_liveMobs -= 1
	_deadMobs += 1
	print("Mob death: " + str(_deadMobs) + " dead vs " + str(maxMobs) + " max")
	if _deadMobs >= maxMobs:
		_active = false
		print("Horde spawn - all children dead")
		if triggerTargetName != "":
			get_tree().call_group("entities", "on_trigger_entities", triggerTargetName)
