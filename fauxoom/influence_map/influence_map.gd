extends Spatial

onready var _texRect:TextureRect = $CanvasLayer/TextureRect
onready var _mesh:MeshInstance = $mesh

# grid size
export var width:int = 100
export var height:int = 100
# size of a cell in engine units - currently only 1 works!
export var cellSize:float = 1
export var tickRate:float = 0.2

export var enemyTemplateTexture:StreamTexture

export var autoUpdate:bool = true
export var debugDraw2d:bool = false
export var debugDraw3d:bool = false

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


var _tick:float = 1

# agent influence templates
var _playerTemplate:Image
var _playerTemplateRect:Rect2 = Rect2()

# agent enemy template
var _enemyTemplate:Image

var _agents = []

func _ready():
	# force cell size atm
	cellSize = 1
	add_to_group(Groups.INFLUENCE_GROUP)
	add_to_group(Groups.CONSOLE_GROUP_NAME)

	_texRect.visible = debugDraw2d
	_mesh.visible = debugDraw3d


	if _material == null:
		_material = SpatialMaterial.new()
	if width <= 0:
		width = 1
	if height <= 0:
		height = 1
	_halfWidth = int(width / 2.0)
	_halfHeight = int(height / 2.0)
	# assuming zero zero atm
	var pos:Vector3 = global_transform.origin
	_worldMin.x = pos.x - (_halfWidth * cellSize)
	_worldMin.y = pos.z - (_halfHeight * cellSize)
	_worldMax.x = pos.x + (_halfWidth * cellSize)
	_worldMax.y = pos.z + (_halfHeight * cellSize)
	scale = Vector3(_halfWidth * cellSize, 1, _halfHeight * cellSize)
	
	_playerTemplate = _build_template(13, 13, Color(0, 1, 0, 1))
	_enemyTemplate = _build_template(9, 9, Color(1, 0, 0, 1))

#	var image = load("res://influence_map/assets/sphere_blend_17x17.png")
#	var data:Image = image.get_data()
	_enemyTemplate = enemyTemplateTexture.get_data()
	_enemyTemplate.convert(Image.FORMAT_RGBAF)
	# _enemyTemplate = enemyTemplateTexture

	# enemyTemplateTexture = ImageTexture.new()
	# enemyTemplateTexture.load("res://influence_map/assets/sphere_blend_17x17.png")
	# _enemyTemplate = enemyTemplateTexture.get_data()
	# if enemyTemplateTexture == null:
	# 	print("Enemy template texture is null")
	# 	_enemyTemplate = _build_template(9, 9, Color(1, 0, 0, 1))
	# else:
	# 	_enemyTemplate = enemyTemplateTexture.get_data()
	# _enemyTemplate = Image.new()
	# _enemyTemplate.load("res://influence_map/assets/sphere_blend_17x17.png")
	_build_texture()
	get_tree().call_group(Groups.INFLUENCE_GROUP, Groups.INFLUENCE_FN_REGISTER_MAP, self)

func _exit_tree():
	get_tree().call_group(Groups.INFLUENCE_GROUP, Groups.INFLUENCE_FN_DEREGISTER_MAP, self)

func influence_map_add(node) -> void:
	_agents.push_back(node)

func influence_map_remove(node) -> void:
	var i:int = _agents.find(node)
	if i == -1:
		return
	_agents.remove(i)

func _build_template(newWidth:int, newHeight:int, colour:Color) -> Image:
	var newImage:Image = Image.new()
	newImage.create(newWidth, newHeight, false, Image.FORMAT_RGBAF)
	newImage.fill(colour)
	# _playerTemplateRect.size = Vector2(8, 8)
	return newImage

func _build_texture() -> void:
	_tex = ImageTexture.new()
	_img = Image.new()
	_img.create(width, height, false, Image.FORMAT_RGBAF)
	_img.fill(Color(0, 0, 1, 1))
	_img.lock()
	_img.set_pixel(0, 0, Color(1, 0, 0, 1))
	# _img.set_pixel(0, 25, Color.red)
	_img.unlock()
	print("Source format " + str(_enemyTemplate.get_format()) + " target format: " + str(_img.get_format()))
	_tex.create_from_image(_img)
	_material.set_texture(SpatialMaterial.TEXTURE_ALBEDO, _tex)
	_mesh.material_override = _material

func _reset() -> void:
	_img.fill(Color(0, 0, 0, 0.25))
	_tex.create_from_image(_img)
	_material.set_texture(SpatialMaterial.TEXTURE_ALBEDO, _tex)
	_texRect.texture = _tex

func find_closest_no_green(_worldOrigin:Vector3) -> Vector2:
	var searchStart:Vector2 = world_to_grid(_worldOrigin)
	var result:Vector2 = searchStart
	var resultDistSqr:float = 99999
	var resultColour:Color = Color(0, 1, 0, 1)

	var w:int = width
	var h:int = height
	_img.lock()
	for _y in range(0, h):
		for _x in range(0, w):
			# don't bother searching IN the origin
			if _x == searchStart.x && _y == searchStart.y:
				continue
			
			var queryPos:Vector2 = Vector2(_x, _y)
			var queryColour:Color = _img.get_pixel(_x, _y)

			# if this cell more green, ignore
			if queryColour.g > resultColour.g:
				continue
			elif queryColour.g < queryColour.g:
				# this cell has an improved score, replace
				var queryDistSqr:float = searchStart.distance_squared_to(queryPos)
				result = queryPos
				resultDistSqr = queryDistSqr
				resultColour = queryColour
				pass
			elif queryColour.g == queryColour.g:
				# cells are equal, compare distance
				var queryDistSqr:float = searchStart.distance_squared_to(queryPos)
				if queryDistSqr < resultDistSqr:
					# nearer, replace
					result = queryPos
					resultDistSqr = queryDistSqr
					resultColour = queryColour
	_img.unlock()
	return result

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
		autoUpdate = true
	elif _tokens[1] == "manual":
		autoUpdate = false
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

func _draw_template_by_world_pos(template:Image, worldPos:Vector3) -> void:
	var gridPos:Vector2 = world_to_grid(worldPos)
	var blitPos:Vector2 = gridPos
	blitPos.x -= template.get_width() / 2.0
	blitPos.y -= template.get_height() / 2.0
	# blit template
	# _img.blit_rect(template, template.get_used_rect(), blitPos)
	_img.blend_rect(template, template.get_used_rect(), blitPos)

func _blit_forward(_gridOrigin:Vector2, _forward:Vector2, _step:float, _count:int) -> void:
	_forward = _forward * _step
	var blitPos:Vector2
	for _i in range(0, _count):
		_gridOrigin.x += _forward.x
		_gridOrigin.y += _forward.y

		blitPos = _gridOrigin
		blitPos.x -= _playerTemplate.get_width() / 2.0
		blitPos.y -= _playerTemplate.get_height() / 2.0
		_img.blit_rect(_playerTemplate, _playerTemplate.get_used_rect(), blitPos)

func _rebuild() -> void:
	_reset()
	_img.lock()

	# paint player pos
	_tickInfo = AI.get_player_target()
	if _tickInfo.id != 0:
		var gridPos:Vector2 = world_to_grid(_tickInfo.position)
		var playerGridPos:Vector2 = gridPos
		# var rect:Rect2 = _playerTemplate.
		var blitPos:Vector2 = gridPos
		blitPos.x -= _playerTemplate.get_width() / 2.0
		blitPos.y -= _playerTemplate.get_height() / 2.0
		# blit template
		_img.blit_rect(_playerTemplate, _playerTemplate.get_used_rect(), blitPos)

		var forward:Vector3 = _tickInfo.flatForward
		var forward2d:Vector2 = Vector2(-forward.x, forward.z)
		_blit_forward(gridPos, forward2d, 8, 3)
		var radians = forward2d.angle()
		forward2d.x = cos(radians - 0.3)
		forward2d.y = sin(radians - 0.3)
		_blit_forward(gridPos, forward2d, 8, 3)

		forward2d.x = cos(radians + 0.3)
		forward2d.y = sin(radians + 0.3)
		_blit_forward(gridPos, forward2d, 8, 3)

		# blit forward from player
		# var step:float = 8
		# var forward:Vector3 = _tickInfo.flatForward
		# forward = forward * step
		# for _i in range (0, 3):
		# 	gridPos.x += -forward.x
		# 	gridPos.y += forward.z

		# 	blitPos = gridPos
		# 	blitPos.x -= _playerTemplate.get_width() / 2.0
		# 	blitPos.y -= _playerTemplate.get_height() / 2.0
		# 	_img.blit_rect(_playerTemplate, _playerTemplate.get_used_rect(), blitPos)

		_img.set_pixel(int(playerGridPos.x), int(playerGridPos.y), Color.white)
		# _img.set_pixel(0, 25, Color.red)
	
	# paint enemies
	for _i in range(0, _agents.size()):
		var agent:Spatial = _agents[_i]
		var agentOrigin:Vector3 = agent.global_transform.origin
		_draw_template_by_world_pos(_enemyTemplate, agentOrigin)
		# draw nearest outside player focus
		var dest:Vector2 = find_closest_no_green(agentOrigin)
		_img.lock()
		_img.set_pixel(int(dest.x), int(dest.y), Color.blue)
		_img.unlock()
	
	_img.unlock()
	_tex.create_from_image(_img)
	_material.set_texture(SpatialMaterial.TEXTURE_ALBEDO, _tex)

func _process(_delta:float) -> void:
	if !autoUpdate:
		return
	
	if _tick <= 0:
		_tick = tickRate
		_rebuild()
	else:
		_tick -= _delta
