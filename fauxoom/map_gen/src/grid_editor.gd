extends Spatial
class_name GridEditor

# visual map display - must refresh on map changes
onready var _mapGen:MapGen = $map_gen
# text displaying current edit state
onready var _paintLabel:Label = $ui/paint/paint_type_label

# injected from controller
var _mapDef:MapDef = null

# updated from controller
var _gridX:int = 0
var _gridY:int = 0

# state
var _isActive:bool = false
var _paintType:int = 1
var _neighbourFlags:int = 0

func init(newMapDef:MapDef) -> void:
	_mapDef = newMapDef
	refresh()

func set_active(flag:bool) -> void:
	_isActive = flag
	if _isActive:
		$ui/paint.visible = true
	else:
		$ui/paint.visible = false

func refresh() -> void:
	if !_mapGen.build_world_map(_mapDef):
		print("Error failed to build map")

func _update_paint_label() -> void:
	var txt:String = "CELL: " + str(_gridX) + ", " + str(_gridY) + "\n"
	if _neighbourFlags != 0:
		txt += "Neighbours (" + str(_neighbourFlags) + "): "
		if _neighbourFlags & MapDef.NEIGHBOUR_FLAG_NORTH > 0:
			txt += "NORTH, "
		if _neighbourFlags & MapDef.NEIGHBOUR_FLAG_SOUTH > 0:
			txt += "SOUTH, "
		if _neighbourFlags & MapDef.NEIGHBOUR_FLAG_EAST > 0:
			txt += "EAST, "
		if _neighbourFlags & MapDef.NEIGHBOUR_FLAG_WEST > 0:
			txt += "WEST, "
		txt += "\n"
	txt += "Painting " + str(_paintType) + "\n"
	_paintLabel.text = txt

func update_cursor_pos(gridX:int, gridY:int) -> void:
	_gridX = gridX
	_gridY = gridY
	if !_mapDef.is_pos_safe(_gridX, _gridY):
		_neighbourFlags = 0
	else:
		var hoverType:int = _mapDef.get_type_at(_gridX, _gridY)
		_neighbourFlags = _mapDef.get_neighbour_flags(_gridX, _gridY, hoverType)

func process_click() -> void:
	var tileType:int = _paintType
	if _mapDef.is_pos_safe(_gridX, _gridY):
		if _mapDef.set_at(tileType, _gridX, _gridY):
			# print("Paint " + str(tileType) + " at " + str(x) + ", " + str(y))
			refresh()

func process_right_click() -> void:
	pass

func update(_delta:float) -> void:
	if Input.is_action_just_pressed("slot_1"):
		_paintType = 0
	if Input.is_action_just_pressed("slot_2"):
		_paintType = 1
	if Input.is_action_just_pressed("slot_3"):
		_paintType = 2
	
	_update_paint_label()
