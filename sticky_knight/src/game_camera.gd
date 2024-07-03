extends Camera2D

var _gameParent = null
var _trackTarget = null

func _ready():
	_gameParent = get_parent()
	#current = true

func _set_target(_newTarget):
	if _trackTarget != null:
		_trackTarget.disconnect("tree_exiting", Callable(self, "on_target_exiting"))
		var globalPos
		if is_inside_tree():
			globalPos = global_position
			print("Cam in tree - global pos " + str(globalPos))
		else:
			globalPos = position
			print("Cam not in tree - pos " + str(globalPos))
		_trackTarget.remove_child(self)
		_gameParent.add_child(self)
		_trackTarget = null
		global_position = globalPos
	if _newTarget != null:
		_trackTarget = _newTarget
		#var globalPos = _trackTarget.global_position
		_trackTarget.connect("tree_exiting", Callable(self, "on_target_exiting"))
		position = Vector2()
		_gameParent.remove_child(self)
		_trackTarget.add_child(self)
		
		#global_position = globalPos
		print("Cam following target at " + str(global_position))

func on_player_register_player_start(_start):
	global_position = _start.global_position
	print("Cam viewing player start at " + str(global_position))

func on_editor():
	print("Cam - on editor - reset")
	position = Vector2()

func on_target_exiting():
	_set_target(null)

func on_player_start(_player):
	_set_target(_player)

func on_player_finish(_player):
	_set_target(null)
