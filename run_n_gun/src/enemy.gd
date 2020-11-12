extends Actor

onready var _life: Life = $life
signal enemy_died
var _dir = Vector2()
var _moveTick:float = 0

func _ready():
	_life.connect("on_death", self, "on_death")

func on_death():
	queue_free()
	emit_signal("enemy_died")

func _choose_wander_dir():
	var radians = rand_range(0, 360) * Game.DEG2RAD
	var result:Vector2
	result.x = cos(radians)
	result.y = sin(radians)
	return result

func _physics_process(_delta):
	_moveTick -= _delta
	if _moveTick <= 0:
		_moveTick = 2
		_dir = _choose_wander_dir()
	_velocity = _calc_velocity(_velocity, _dir, 100)
	move_and_slide(_velocity)
	pass
