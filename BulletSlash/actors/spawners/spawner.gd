extends Node3D

const STATE_WAITING:String = "waiting"
const STATE_MONITORING:String = "monitoring"
const STATE_SPAWNING:String = "spawning"

@export var id:String = ""
@export var mobType:String = "dummy"
@export var maxLiveMobs:int = 2.0
@export var spawnInterval:float = 1.0

var _spawnedMobs:Dictionary = {}

var _state:String = STATE_WAITING

var _spawnTick:float = 0.0

func _ready() -> void:
	self.add_to_group(Game.GROUP_TRIGGER_EVENTS)

func trigger_event(ids:PackedStringArray, eventType:String, data:Dictionary) -> void:
	if id == "":
		return
	var i:int = ids.find(id)
	if i >= 0:
		start()

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

func start() -> void:
	if _state == STATE_WAITING:
		_state = STATE_MONITORING

func _physics_process(_delta:float) -> void:
	match _state:
		STATE_MONITORING:
			if _spawnedMobs.size() == 0:
				_spawnTick = spawnInterval
				_state = STATE_SPAWNING
		STATE_SPAWNING:
			_spawnTick += _delta
			if _spawnTick >= spawnInterval:
				_spawnTick = 0.0
				spawn_mob()
				if _spawnedMobs.size() >= maxLiveMobs:
					_state = STATE_MONITORING
