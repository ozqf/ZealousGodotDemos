extends Actor

var _ai_info_t = preload("res://src/ai/ai_info.gd")

onready var _aiTree:AINode = $ai_tree
onready var _life: Life = $life
var _aiInfo:AIInfo = null
signal enemy_died
var _dir = Vector2()
var _moveTick:float = 0

var _tickTime:float = 0
var _tickMax:float = 0.25
var _deltaAccumulator:float = 0

func _ready():
	_life.connect("on_death", self, "on_death")
	_aiInfo = _ai_info_t.new()
	_aiInfo.mob = self

func on_death():
	queue_free()
	emit_signal("enemy_died")

func _physics_process(_delta):
	_tickTime -= _delta
	_deltaAccumulator += _delta
	if _tickTime <= 0:
		# run ai tree
		print("--- AI Tick " + str(_aiInfo.frames) + " ---")
		_tickTime = _tickMax
		# _aiInfo.delta = _delta
		_aiInfo.delta = _deltaAccumulator
		_aiInfo.selfPosition = global_position
		_deltaAccumulator = 0
		_aiTree.tick(_aiInfo)
		_aiInfo.frames += 1
