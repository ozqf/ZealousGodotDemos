extends Node3D

var _gas_sac_t = preload("res://prefabs/dynamic_entities/mob_gas_sac.tscn")

@export var respawnTime:float = 0.5
@export var count:int = 30

var _tick:float = 0.5
var _state:int = 0

func _ready() -> void:
	_tick = respawnTime

func _process(_delta:float) -> void:
	var plyr:Dictionary = AI.get_player_target()
	if plyr.id == 0:
		return
	if _state == 0:
		var pos:Vector3 = global_transform.origin
		if ZqfUtils.los_check(self, pos, plyr.position, Interactions.WORLD):
			_state = 1
	elif _state == 1:
		_tick -= _delta
		if _tick > 0:
			return
		_tick = respawnTime
		var pos:Vector3 = global_transform.origin
		var mob = _gas_sac_t.instance()
		Game.get_dynamic_parent().add_child(mob)
		mob.global_transform.origin = pos
		count -= 1
		if count <= 0:
			_state = 2
