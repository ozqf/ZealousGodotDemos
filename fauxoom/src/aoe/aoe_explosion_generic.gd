extends Node

onready var _area:ZqfVolumeScanner = $Area
export var damage:int = 100

var _dead:bool = false
var _tick:int = 0

var _hitInfo:HitInfo

func _ready() -> void:
	_hitInfo = Game.new_hit_info()
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_EXPLOSIVE

func _run_hits() -> void:
	if _area.total > 0:
		print("AoE saw " + str(_area.total) + " hits")
	pass

func _physics_process(_delta:float):
	if _dead:
		return
	_tick += 1
	if _tick == 2:
		_run_hits()
		pass
	elif _tick == 60:
		self.queue_free()
		_dead = true
		return

