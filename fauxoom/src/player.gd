extends KinematicBody
class_name Player

onready var _head:Camera = $head
onready var _motor:FPSMotor = $motor
onready var _attack:PlayerAttack = $attack
onready var _hud:Hud = $hud

var _inputOn:bool = false

func _ready():
	game.set_camera(_head)
	_motor.init_motor(self, _head)
	_motor.set_input_enabled(false)
	_attack.init_attack(_head, self)
	_attack.set_attack_enabled(false)
	
	var _foo = _attack.connect("fire_ssg", _hud, "on_shoot_ssg")
	_foo = _attack.connect("change_weapon", _hud, "on_change_weapon")
	_foo = connect("tree_exiting", self, "_on_tree_exiting")

func _on_tree_exiting() -> void:
	game.clear_camera(_head)

func _refresh_input_on() -> void:
	var flag:bool = game.get_input_on()
	_motor.set_input_enabled(flag)
	_attack.set_attack_enabled(flag)

func _process(_delta):
	_refresh_input_on()
