extends Node

var _bouncer_t = preload("res://entities/bouncer.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Game init")


func _process(_delta:float) -> void:
	_read_input()

func _read_input():
	# ui_accept, ui_select, ui_cancel, ui_up/down/left/right
	if Input.is_action_just_pressed("ui_select"):
		# spawn player
		print("GAME Spawn player")
		var obj = _bouncer_t.instance()
		add_child(obj)
		obj.position = Vector2(256, 256)
		pass
	pass
