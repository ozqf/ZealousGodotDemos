extends Node3D
class_name QuickSpawner

signal completed(spawnerInstance)

var _mobileTrainingDummyType = preload("res://actors/mobs/mobile_training_dummy/mobile_training_dummy.tscn")
var _fodderType = preload("res://actors/mobs/fodder/mob_fodder.tscn")
var _bouncerType = preload("res://actors/mobs/bouncer/mob_bouncer.tscn")
var _bruteType = preload("res://actors/mobs/brute/brute.tscn")

@export var totalMobs:int = 2
@export var maxLiveMobs:int = 1
@export var waitTime:float = 0.5

@export var mobType:GameCtrl.MobType = GameCtrl.MobType.Fallback

@onready var _timer:Timer = $spawn_timer

var _liveMobs:int = 0
var _capacity:int = 0

func _ready():
	print("Created spawner")
	_timer.connect("timeout", _on_timeout)
	self.visible = false

func restart() -> void:
	_timer.one_shot = true
	_timer.wait_time = waitTime
	_timer.start()
	_capacity = totalMobs

func _get_mob_type_obj():
	match mobType:
		GameCtrl.MobType.Fodder:
			return _fodderType
		GameCtrl.MobType.Brute:
			return _bruteType
		GameCtrl.MobType.MobileTrainingDummy:
			return _mobileTrainingDummyType
		_:
			return _bruteType

func _on_timeout() -> void:
	_timer.start()
	if _liveMobs >= maxLiveMobs:
		return
	if _capacity <= 0:
		return
#	print("Spawn!")
	for _i in range(0, 1):
		_liveMobs += 1
		_capacity -= 1
		#var mob:Node3D = Game.add_actor_scene(_bouncerType, self.global_transform)
		var mob:Node3D = Game.add_actor_scene(_get_mob_type_obj(), self.global_transform)
		mob.connect("tree_exited", _on_mob_exited_tree)
		mob.launch()

func _on_mob_exited_tree() -> void:
	_liveMobs -= 1
	if _liveMobs <= 0 && _capacity <= 0:
		print("Spawner finished")
		_timer.stop()
		self.emit_signal("completed", self)
