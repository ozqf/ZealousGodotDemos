extends Node2D

onready var _cursor:Node2D = $tile_cursor
onready var _world:TileMap = $tile_maps/world

var _tilePos:Vector2 = Vector2()

func _ready():
	get_tree().call_group("game", "on_editor")

func _set_cursor_pos():
	# get world position of cursor
	var scrSize := OS.get_screen_size()
	#scrSize /= 128
	var mPos := get_viewport().get_mouse_position()
	mPos -= (scrSize / 4)
	mPos -= Vector2(32, 32)
	# get tile position of cursor
	_tilePos = _world.world_to_map(mPos)
	# snap cursor to tile pos
	_cursor.position = Vector2(_tilePos.x * 32, _tilePos.y * 32)

func _physics_process(delta):
	_set_cursor_pos()
	if Input.is_action_pressed("jump"):
		print("Add tile at " + str(_tilePos))
		_world.set_cell(_tilePos.x, _tilePos.y, 0)
	pass
