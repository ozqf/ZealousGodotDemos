extends KinematicBody
class_name Player

onready var _head:Camera = $head
onready var _motor:FPSMotor = $motor
onready var _attack:PlayerAttack = $attack
onready var _hud:Hud = $hud

var _inputOn:bool = false

func _ready():
	Main.set_camera(_head)
	
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	
	_motor.init_motor(self, _head)
	_motor.set_input_enabled(false)
	_attack.init_attack(_head, self)
	_attack.set_attack_enabled(false)
	
	var _foo = _attack.connect("fire_ssg", _hud, "on_shoot_ssg")
	_foo = _attack.connect("change_weapon", _hud, "on_change_weapon")
	_foo = connect("tree_exiting", self, "_on_tree_exiting")

	Game.register_player(self)

func _on_tree_exiting() -> void:
	Game.deregister_player(self)
	Main.clear_camera(_head)

func console_on_exec(_txt:String) -> void:
	if _txt == "kill":
		kill()

func game_on_level_completed() -> void:
	kill()

func _refresh_input_on() -> void:
	var flag:bool = Main.get_input_on()
	_motor.set_input_enabled(flag)
	_attack.set_attack_enabled(flag)

func _process(_delta):
	_refresh_input_on()

func kill() -> void:
	var info:Dictionary = {}
	get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_PLAYER_DIED, info)
	queue_free()
