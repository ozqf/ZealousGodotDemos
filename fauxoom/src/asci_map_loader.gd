extends Node
class_name AsciMapLoader
const _map_t = preload("res://map_gen/src/map_def.gd")
const _spawnDef_t = preload("res://map_gen/src/map_spawn_def.gd")

const asci0:String = """#####
#. .#
# s #
#. .#
#####
"""

const asci1:String = """#
s
.
"""

const asci2:String = """########################################x  ......###############
######################################     ......###############
##########################...#### x ##x    .......##############
###################...####...####        x .###....  x  ########
###################....###......           .###....     ########
###################...####....  x   x   x  .##  x       ########
###########.....###...####....          x      x      ##########
###########.....###...###.....                        ##########
###########.....###....#.......          x    x  x . ..#########
############....###............ . k  x  .  x    x  . ..#########
############................... ..  ##x            .   #########
############................... ..####   x ....#x  . x #########
############.......#........... ..###..   ......   x   #########
#############....###..........k ..###.............. # ##########
############# x .####...#..... x..###...##......    # ##########
#############x xx       x  x x              x  x    #s##########
#############     .#######.   x .######...#.####x  .############
##############x     ######.  x. ######....#.####################
###############    x     #.x  .   #####.....####################
##################             x  ##############################
##################       x   .. #e##############################
################    #  x      .x################################
################              . #...############################
################       # x    .x#...############################
####################  x#  xx     ...############################
#####################   x    x   ...############################
#####################          x ...############################
#################### x  x          #############################
#################### x           x #############################
####################         #x    #############################
####################        x###################################
######################   #######################################
"""

const asci3:String = """################################################################
#################...###...######################################
#################...#.......####################################
#################.................#########################...##
#################...#...#.........#########################....#
#################....####...x  ...################...###.......#
##################...##...##x   .#################.............#
##################........#     .#################...###..   ..#
#######################...#  x. ##################.   #      ..#
###########################   . ..#############....     x    ..#
############################x#. xx#############....   #x     ###
############################ x    #############...   ....# xx  #
#########..#################    x  ############...   ....#   x #
######x x..#####   ##########      ############...   ....#   x##
######    ....      xxx########  x ############..     ###   ####
######    ..   x      x            x           x  x   ..#x######
#######x  ..    x ###   ####### ###############       ..# ######
#######           ###     x####   ############ex  ###x..# ######
#######...## ##   ######     ## # ############ x ####     ######
#######...# x    x######     ## # ###################     ######
########.#.    x x  ######   ## # ####################   #######
########...   xxx   ####### x #x#x  ############################
#######......##     #######   # ##  ###...##...#################
#####.......###     ##k         ##  #     .....#################
#####......####     #####             s   ......################
#####...#..#####      ### xx  x      .. x ........###########.##
####....#...####      ####     x     ...#####.....##...######.##
####....###....     xx       x.. .x  ##########....#...######.##
####..###......   # x ###        ## ##############.....###....##
#########......    k#####  x     x   #############.....###....##
#########...#############  x       x ##############..........###
################################################################
"""

const asci4:String = """x  ..#
..  ..
#..  s
"""

static func get_default() -> String:
	# var str:String = asci3
	# test_base64()
	#return asci0
	return asci4
	#return asci3
	#return asci2
	#return asci1

################################################
# build MapDef from asci grid
################################################

static func build_test_map() -> MapDef:
	# var m:MapDef = _map_t.new()
	# m.load_from_asci(asci4)
	var m:MapDef = load_from_asci(asci4)
	if m == null:
		print("ERROR Failed to load map from asci")
		return null
	print("build test map:")
	# print(m.debug_print_cells())
	return m

static func char_to_tile_type(c:String) -> int:
	if c == '#':
		return MapDef.TILE_WALL
	elif c == '.':
		return MapDef.TILE_VOID
	else:
		return MapDef.TILE_PATH

static func char_to_ent(c:String, x:int, y:int) -> MapSpawnDef:
	var newType:int = MapDef.ENT_TYPE_NONE
	if c == 'x':
		# print("Spawn mob at " + str(x) + ", " + str(y))
		newType = MapDef.ENT_TYPE_MOB_GRUNT
	elif c == 's':
		newType = MapDef.ENT_TYPE_START
	elif c == 'e':
		newType = MapDef.ENT_TYPE_END
	elif c == 'k':
		newType = MapDef.ENT_TYPE_KEY
	
	# didn't get anything?
	if newType == MapDef.ENT_TYPE_NONE:
		return null
	
	var spawn:MapSpawnDef = _spawnDef_t.new()
	spawn.type = newType
	spawn.position = Vector3(x, 0, y)
	spawn.yaw = int(rand_range(0, 359))
	return spawn

static func load_from_asci(txt:String) -> MapDef:
	
	txt = txt.replace("\r", "")
	# print("Load test map from asci")
	# print(txt)
	var lines:PoolStringArray = txt.split("\n", false)
	# \n will break up each row, but assume row widths might be
	# different and should be measured
	var longest:int = 0
	for i in range(0, lines.size()):
		var length = lines[i].length()
		if length > longest:
			longest = length
	if longest == 0 || lines.size() == 0:
		print("Read 0 width or height from map asci")
		return null
	var newWidth:int = longest
	var newHeight:int = lines.size()
	var _newCells:PoolIntArray = []
	var _newSpawns = []
	for y in range(0, lines.size()):
		var line = lines[y]
		for x in range(0, line.length()):
			var c:String = line[x]
			var tileType:int = char_to_tile_type(c)
			_newCells.push_back(tileType)
			var spawn:MapSpawnDef = char_to_ent(c, x, y)
			if spawn:
				_newSpawns.push_back(spawn)
		var pad:int = longest - line.length()
		for _i in range(0, pad):
			_newCells.push_back(MapDef.TILE_WALL)
	
	# loaded chucks successfully
	var map:MapDef = MapDef.new()
	map.width = newWidth
	map.height = newHeight
	map.cells = _newCells
	map.spawns = _newSpawns
	return map

################################################
# encoding scribbles
################################################

static func str_to_b64(source:String) -> String:
	var srcBytes:PoolByteArray = source.to_utf8()
	var b64:String = Marshalls.raw_to_base64(srcBytes)
	return b64

static func test_base64() -> String:
	# b64 encodes 6 bits per char
	var source:String = asci3
#	print("Source chars: " + str(source.length()))
#	var srcBytes:PoolByteArray = source.to_utf8()
#	var compressed = srcBytes.compress()
#	print("String bytes " + str(srcBytes.size()) + " compressed bytes: " + str(compressed.size()))
#	var b64:String = Marshalls.raw_to_base64(compressed)
	var b64 = str_to_b64(source)
	print("b64 chars: " + str(b64.length()))
	return b64

static func _measure_line(txt:String) -> int:
	var i:int = 0
	var c = txt[i]
	while c != '\n' && c != '\r':
		i += 1
		c = txt[i]
	return i

static func read_string(txt:String) -> Dictionary:
	print("Asci map loader - read string len " + str(txt.length()))
	txt = txt.replace("\r", "")
	var lines:PoolStringArray = txt.split("\n", false)
	var longest:int = 0
	for i in range (0, lines.size()):
		var length = lines[i].length()
		if length > longest:
			longest = length
	return {
		width = longest,
		height = lines.size(),
		lines = lines
	}
