extends Node

var _triggers = []
var _spawners = []
var _completedSpawners:int = 0

var _barriers = []

var _state:int = 0

func _ready():
	call_deferred("_attach_components")

func _attach_components() -> void:
	for child in get_children():
		if child is TriggerVolume:
			_triggers.push_back(child)
			child.connect("triggered", _on_trigger_touched)
		elif child is QuickSpawner:
			_spawners.push_back(child)
		elif child is PlayerBarrierVolume:
			_barriers.push_back(child)
			child.set_active(false)
	pass

func _on_trigger_touched(_triggerInstance, _toucher) -> void:
	if _state != 0:
		return
	_triggerInstance.set_active(false)
	_start()

func _start() -> void:
	_state = 1
	_completedSpawners = 0
	for item in _barriers:
		item.set_active(true)
	for item in _spawners:
		var spawner:QuickSpawner = (item as QuickSpawner)
		spawner.connect("completed", _spawner_completed)
		spawner.restart()

func _finish() -> void:
	for item in _barriers:
		item.set_active(false)

func _spawner_completed(_spawner) -> void:
	_completedSpawners += 1
	if _completedSpawners >= _spawners.size():
		_finish()
