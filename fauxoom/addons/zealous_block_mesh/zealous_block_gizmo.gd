extends EditorSpatialGizmo

# var value:float = 1

var _drawInternal:bool = false
var _drawCentre:bool = true
var _drawBounds:bool = true


# handle value callback
#func set_handle(index:int, camera:Camera, point:Vector2):
#	var v = 0
##	v = gizmo.get_handle_name(index)
#	# get_handle_value doesn't exist...?
#	# var v = gizmo.get_handle_value(index)
##	print("Handle " + str(index) + " value: " + str(v) + " has - " + str(gizmo.has_method("get_handle_value")))
##	print("Handle " + str(index) + " value: " + str(v) + " has - " + str(self.has_method("get_handle_value")))
#	print("Handle " + str(index) + " value: " + str(v) + " has - " + str(point))

func get_handle_name(index:int):
	if index == 0:
		return "-x"
	elif index == 1:
		return "+x"
	return "?"

func get_handle_value(index:int):
	return self.get_spatial_node().value

func commit_handle(index:int, restore, cancel:bool = false):
	print("Commit handle " + str(index) + " value: " + str(self.get_spatial_node().value) + " restore " + str(restore))
	# value = restore

func redraw():
	_draw_grid_gizmo()
#	_draw_signal_gizmo()

func _draw_signal_gizmo():
	pass

func _draw_grid_gizmo():
	self.clear()
	
	var foo = self.get_spatial_node()
	var spatial = foo as ZealousBlock
	# var spatial:ZealousBlock = self.get_spatial_node() as ZealousBlock # doesn't like this line...?
	
#	var targetSize:Vector3 = Vector3(1, 1, 1)
	var targetSize:Vector3 = spatial.scale
#	targetSize.x += 1
#	targetSize.y += 1
#	targetSize.z += 1
	
	var scl:Vector3 = Vector3(1, 1, 1) / spatial.scale
	var size:Vector3 = targetSize * scl
	var radius = size / 2
	
	var _min:Vector3 = radius * -1
	
	var purpleLines = PoolVector3Array()
	var cyanLines = PoolVector3Array()
	
	#####################################
	# centre widget - extends of object from inside - not really useful
	# draw infront doesn't work
	#####################################
	if _drawInternal:
		purpleLines.push_back(Vector3(0, radius.y, 0))
		purpleLines.push_back(Vector3(0, -radius.y, 0))
		
		purpleLines.push_back(Vector3(-radius.x, 0, 0))
		purpleLines.push_back(Vector3(radius.x, 0, 0))

		purpleLines.push_back(Vector3(0, 0, -radius.z))
		purpleLines.push_back(Vector3(0, 0, radius.z))
	
	#####################################
	# lines out from centre of each plane
	#####################################
	if _drawCentre:
		# top
		purpleLines.push_back(Vector3(-radius.x - scl.x, radius.y, 0))
		purpleLines.push_back(Vector3(radius.x + scl.x, radius.y, 0))

		purpleLines.push_back(Vector3(0, radius.y, -radius.z - scl.z))
		purpleLines.push_back(Vector3(0, radius.y, radius.z + scl.z))
		
		# bottom
		purpleLines.push_back(Vector3(-radius.x - scl.x, -radius.y, 0))
		purpleLines.push_back(Vector3(radius.x + scl.x, -radius.y, 0))

		purpleLines.push_back(Vector3(0, -radius.y, -radius.z - scl.z))
		purpleLines.push_back(Vector3(0, -radius.y, radius.z + scl.z))
		
		# left
		# across
		purpleLines.push_back(Vector3(-radius.x, 0, -radius.z - scl.z))
		purpleLines.push_back(Vector3(-radius.x, 0, radius.z + scl.z))
		# up
		purpleLines.push_back(Vector3(-radius.x, -radius.y - scl.y, 0))
		purpleLines.push_back(Vector3(-radius.x, radius.y + scl.y, 0))
		
		# right
		# across
		purpleLines.push_back(Vector3(radius.x, 0, -radius.z - scl.z))
		purpleLines.push_back(Vector3(radius.x, 0, radius.z + scl.z))
		# up
		purpleLines.push_back(Vector3(radius.x, -radius.y - scl.y, 0))
		purpleLines.push_back(Vector3(radius.x, radius.y + scl.y, 0))
		
		# front 
		# across
		purpleLines.push_back(Vector3(-radius.x - scl.x, 0, -radius.z))
		purpleLines.push_back(Vector3(radius.x + scl.x, 0, -radius.z))
		
		# up
		purpleLines.push_back(Vector3(0, radius.y - scl.y, -radius.z))
		purpleLines.push_back(Vector3(0, radius.y + scl.y, -radius.z))

		# back 
		# across
		purpleLines.push_back(Vector3(-radius.x - scl.x, 0, radius.z))
		purpleLines.push_back(Vector3(radius.x + scl.x, 0, radius.z))
		
		# up
		purpleLines.push_back(Vector3(0, radius.y - scl.y, radius.z))
		purpleLines.push_back(Vector3(0, radius.y + scl.y, radius.z))


		# purpleLines.push_back(Vector3(-radius.x - scl.x, -radius.y, 0))
		# purpleLines.push_back(Vector3(radius.x + scl.x, -radius.y, 0))
		
		# # y
		# purpleLines.push_back(Vector3(radius.x, -radius.y - scl.y, 0))
		# purpleLines.push_back(Vector3(radius.x, radius.y + scl.y, 0))
		
		# purpleLines.push_back(Vector3(-radius.x, -radius.y - scl.y, 0))
		# purpleLines.push_back(Vector3(-radius.x, radius.y + scl.y, 0))
	
		# # z
		# purpleLines.push_back(Vector3(0, -radius.y, -radius.z - scl.z))
		# purpleLines.push_back(Vector3(0, -radius.y, radius.z + scl.z))
		
		# purpleLines.push_back(Vector3(0, radius.y, -radius.z - scl.z))
		# purpleLines.push_back(Vector3(0, radius.y, radius.z + scl.z))
	
	#####################################
	# edges of block
	#####################################
	if _drawBounds:
			# x
		cyanLines.push_back(Vector3(radius.x + scl.x, radius.y, radius.z))
		cyanLines.push_back(Vector3(-radius.x - scl.x, radius.y, radius.z))
	
		cyanLines.push_back(Vector3(radius.x + scl.x, radius.y, -radius.z))
		cyanLines.push_back(Vector3(-radius.x - scl.x, radius.y, -radius.z))
	
		cyanLines.push_back(Vector3(radius.x + scl.x, -radius.y, radius.z))
		cyanLines.push_back(Vector3(-radius.x - scl.x, -radius.y, radius.z))
	
		cyanLines.push_back(Vector3(-radius.x - scl.x, -radius.y, -radius.z))
		cyanLines.push_back(Vector3(radius.x + scl.x, -radius.y, -radius.z))
	
		# y
		cyanLines.push_back(Vector3(radius.x, radius.y + scl.y, radius.z))
		cyanLines.push_back(Vector3(radius.x, -radius.y - scl.y, radius.z))
	
		cyanLines.push_back(Vector3(radius.x, radius.y + scl.y, -radius.z))
		cyanLines.push_back(Vector3(radius.x, -radius.y - scl.y, -radius.z))
	
		cyanLines.push_back(Vector3(-radius.x, radius.y + scl.y, radius.z))
		cyanLines.push_back(Vector3(-radius.x, -radius.y - scl.y, radius.z))
	
		cyanLines.push_back(Vector3(-radius.x, radius.y + scl.y, -radius.z))
		cyanLines.push_back(Vector3(-radius.x, -radius.y - scl.y, -radius.z))
	
		# z
		cyanLines.push_back(Vector3(-radius.x, -radius.y, radius.z + scl.z))
		cyanLines.push_back(Vector3(-radius.x, -radius.y, -radius.z  - scl.z))
	
		cyanLines.push_back(Vector3(radius.x, -radius.y, radius.z + scl.z))
		cyanLines.push_back(Vector3(radius.x, -radius.y, -radius.z  - scl.z))
	
		cyanLines.push_back(Vector3(-radius.x, radius.y, radius.z + scl.z))
		cyanLines.push_back(Vector3(-radius.x, radius.y, -radius.z  - scl.z))
	
		cyanLines.push_back(Vector3(radius.x, radius.y, radius.z + scl.z))
		cyanLines.push_back(Vector3(radius.x, radius.y, -radius.z  - scl.z))
	
	var numChildren:int = spatial.get_child_count()
	var offset:Vector3 = Vector3()
	for _i in range(0, numChildren):
		var child = spatial.get_child(_i)
		if (child is CollisionShape):
			offset = child.transform.origin
	
	var numLines = purpleLines.size()
	for _i in range(0, numLines):
		purpleLines[_i] += offset
	
	numLines = cyanLines.size()
	for _i in range(0, numLines):
		cyanLines[_i] += offset
	
#	purpleLines.push_back(Vector3(10, 20, 10))
#	purpleLines.push_back(Vector3(10, 10, 10))

	var handles = PoolVector3Array()

	handles.push_back(Vector3(0, 0, 0))
	handles.push_back(Vector3(0, spatial.value, 0))
	# handles.push_back(Vector3(0, 3, 0))
	
	# x scale
#	handles.push_back(Vector3(-radius.x - scl.x, 0, 0))
#	handles.push_back(Vector3(radius.x + scl.x, 0, 0))
	
#	var mat:SpatialMaterial = get_material("main", gizmo)
#	mat.flags_no_depth_test = true
	
	var purpleMat = get_plugin().get_material("purple", self)
	add_lines(purpleLines, purpleMat)
	var cyanMat = get_plugin().get_material("cyan", self)
	add_lines(cyanLines, cyanMat)
	var hmat = get_plugin().get_material("handles", self)
	add_handles(handles, hmat)
