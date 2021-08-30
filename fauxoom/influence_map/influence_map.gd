extends MeshInstance

onready var _texRect:TextureRect = $CanvasLayer/TextureRect

# grid size
export var width:int = 50
export var height:int = 50
# size of a cell in engine units - currently only 1 works!
export var cellSize:float = 1
export var tickRate:float = 0.2

var _material:SpatialMaterial = null
var _img:Image
var _tex:ImageTexture
var _halfWidth:int = 25
var _halfHeight:int = 25
var _worldMin:Vector2 = Vector2()
var _worldMax:Vector2 = Vector2()

var _tickInfo:Dictionary = {
	id = 0,
	trueDistance = 0,
	flatDistance = 0
}

var _autoUpdate:bool = false
var _tick:float = 1

func _ready():
	# force cell size atm
	cellSize = 1

	add_to_group(Groups.CONSOLE_GROUP_NAME)
	if _material == null:
		_material = SpatialMaterial.new()
	if width <= 0:
		width = 1
	if height <= 0:
		height = 1
	_halfWidth = width / 2
	_halfHeight = height / 2
	# assuming zero zero atm
	_worldMin.x = 0 - (_halfWidth * cellSize)
	_worldMin.y = 0 - (_halfHeight * cellSize)
	_worldMax.x = 0 + (_halfWidth * cellSize)
	_worldMax.y = 0 + (_halfHeight * cellSize)
	scale = Vector3(_halfWidth * cellSize, 1, _halfHeight * cellSize)

	_build_texture()

func _build_texture() -> void:
	_tex = ImageTexture.new()
	_img = Image.new()
	_img.create(width, height, false, Image.FORMAT_RGBAF)
	_img.fill(Color(0, 0, 1, 1))
	_img.lock()
	_img.set_pixel(0, 0, Color(1, 0, 0, 1))
	# _img.set_pixel(0, 25, Color.red)
	_img.unlock()
	_tex.create_from_image(_img)
	_material.set_texture(SpatialMaterial.TEXTURE_ALBEDO, _tex)
	self.material_override = _material

func _reset() -> void:
	_img.fill(Color(0, 0, 1, 1))
	_tex.create_from_image(_img)
	_material.set_texture(SpatialMaterial.TEXTURE_ALBEDO, _tex)
	_texRect.texture = _tex

#################################################
# debugging commands
#################################################
func console_on_exec(_txt: String, _tokens:PoolStringArray) -> void:
	if _tokens.size() < 2:
		return
	if _tokens[0] != "ai":
		return
	
	# actual commands
	if _tokens[1] == "auto":
		_autoUpdate = true
	elif _tokens[1] == "manual":
		_autoUpdate = false
	elif _tokens[1] == "recalc":
		_rebuild()
	elif _tokens[1] == "coords":
		print("ai map world extents: " + str(_worldMin) + " to " + str(_worldMax))
	elif _tokens[1] == "player":
		# test find player's position
		_tickInfo = AI.get_player_target()
		if _tickInfo.id == 0:
			return
		var gridPos:Vector2 = world_to_grid(_tickInfo.position)
		print("Player grid pos: " + str(gridPos))
		_reset()
		_img.lock()
		_img.set_pixel(int(gridPos.x), int(gridPos.y), Color(1, 0, 0, 1))
		# _img.set_pixel(0, 25, Color.red)
		_img.unlock()
		_tex.create_from_image(_img)
		_material.set_texture(SpatialMaterial.TEXTURE_ALBEDO, _tex)

func world_to_grid(_worldPos:Vector3) -> Vector2:
	# for now just assuming that the influence map is at 0,0 world
	# so 0, 0 world - (half width of map * size of cells)
	# == world pos of 0, 0 on grid
	var x = _worldPos.x - _worldMin.x
	var y = _worldPos.z - _worldMin.y
	if x < 0:
		x = 0
	if x >= width:
		x = width - 1
	if y < 0:
		y = 0
	if y >= height:
		y = height - 1
	return Vector2(x, y)

func _rebuild() -> void:
	_reset()
	_img.lock()

	# paint player pos
	_tickInfo = AI.get_player_target()
	if _tickInfo.id != 0:
		var gridPos:Vector2 = world_to_grid(_tickInfo.position)
		_img.set_pixel(int(gridPos.x), int(gridPos.y), Color.green)
		# _img.set_pixel(0, 25, Color.red)
	
	# paint enemies
	
	_img.unlock()
	_tex.create_from_image(_img)
	_material.set_texture(SpatialMaterial.TEXTURE_ALBEDO, _tex)

func _process(_delta:float) -> void:
	if !_autoUpdate:
		return
	
	if _tick <= 0:
		_tick = tickRate
		_rebuild()
	else:
		_tick -= _delta
