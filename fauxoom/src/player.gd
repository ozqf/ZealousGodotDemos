extends KinematicBody
class_name Player

onready var _head:Camera = $head
onready var _motor:FPSMotor = $motor

func _ready():
	game.set_camera(_head)
	_motor.init_motor(self, _head)
	_motor.set_input_enabled(true)
	var _foo = connect("tree_exiting", self, "_on_tree_exiting")

func _on_tree_exiting() -> void:
	game.clear_camera(_head)
