extends Actor

const RUN_SPEED = 200.0
const REFIRE_TIME = 0.05
var _attackTick: float = 0
# onready var _door_trigger = 
func _ready():
	$door_trigger.connect("body_entered", self, "_on_door_trigger")
	Game.register_player(self)

func _exit_tree():
	Game.remove_player(self)

func _on_door_trigger(_body):
	if _body.has_method("OpenDoor"):
		_body.OpenDoor()

func _update_attack(_delta:float):
	if (_attackTick > 0):
		_attackTick -= _delta
		return
	if Input.is_action_pressed("attack_1"):
		_attackTick = REFIRE_TIME
		var prj = Game.get_free_player_projectile()
		var mPos = Game.cursorPos
		var radians = mPos.angle_to_point(position)
		radians += rand_range(-0.05, 0.05)
		prj.launch(position, radians)

func _get_input_move():
	var dir = Vector2()
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if Input.is_action_pressed("move_up"):
		dir.y -= 1
	if Input.is_action_pressed("move_down"):
		dir.y += 1
	return dir

func _physics_process(delta):
	var dir = _get_input_move()
	_velocity = _calc_velocity(_velocity, dir, RUN_SPEED)
	move_and_slide(_velocity)
	_update_attack(delta)
	pass
