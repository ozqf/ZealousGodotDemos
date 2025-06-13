extends Node
class_name PlayerInput

var paused:bool = true
var reset:bool = false

var axisX:float = 0
var axisZ:float = 0
var moveUp:bool = false
var moveDown:bool = false
var inputDir:Vector2 = Vector2()
var lookKeys:Vector2 = Vector2()

func _refresh_pause() -> void:
	if paused:
		Game.add_mouse_claim(self)
	else:
		Game.remove_mouse_claim(self)

func _physics_process(_delta) -> void:
	if Input.is_action_just_pressed("pause"):
		paused = !paused
		_refresh_pause()
	
	reset = Input.is_action_just_pressed("reset")
	
	var inputOn:bool = !Game.has_mouse_claims()
	if !inputOn:
		axisX = 0
		axisZ = 0
		moveUp = false
		moveDown = false
		inputDir = Vector2()
		return
	
	axisX = Input.get_axis("move_left", "move_right")
	axisZ = Input.get_axis("move_forward", "move_backward")
	moveUp = Input.is_action_pressed("move_up")
	moveDown = Input.is_action_pressed("move_down")
	inputDir = Vector2(axisX, axisZ)
	lookKeys = Input.get_vector("look_right", "look_left", "look_up", "look_down")
