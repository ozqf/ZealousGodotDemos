extends Node3D

const STATE_MONITORING:String = "monitoring"
const STATE_SPAWNING:String = "spawning"

@export var mobType:String = "dummy"
@export var maxLiveMobs:int = 2.0
@export var spawnInterval:float = 1.0

var _spawnedMobs:Dictionary = {}

var _state:String = "monitoring"

var _spawnTick:float = 0.0

func spawn_mob():
	var mob:MobBase = null
	match mobType:
		"fodder":
			mob = Game.spawn_mob_fodder() as MobBase
		_:
			mob = Game.spawn_mob_dummy() as MobBase
	var spawnInfo:MobSpawnInfo = mob.get_spawn_info()
	spawnInfo.t = self.global_transform
	mob.spawn()
	_spawnedMobs[spawnInfo.uuid] = mob
	mob.connect("mob_broadcast_event", _on_mob_broadcast_event)

func _on_mob_broadcast_event(eventType, mobInstance) -> void:
	var id:String = mobInstance.get_id()
	match eventType:
		MobBase.MOB_EVENT_DIED:
			if _spawnedMobs.has(id):
				_spawnedMobs.erase(id)
	pass

func _physics_process(_delta:float) -> void:
	match _state:
		STATE_MONITORING:
			if _spawnedMobs.size() == 0:
				_spawnTick = 0.0
				_state = STATE_SPAWNING
		STATE_SPAWNING:
			_spawnTick += _delta
			if _spawnTick >= spawnInterval:
				_spawnTick = 0.0
				spawn_mob()
				if _spawnedMobs.size() >= maxLiveMobs:
					_state = STATE_MONITORING
