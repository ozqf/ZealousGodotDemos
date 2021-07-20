extends EditorSpatialGizmoPlugin

var bShow:bool = true

var _drawCentre:bool = true
var _drawBounds:bool = true

func get_name() -> String:
	return "Zealous Grid"

func _init() -> void:
	create_material("main", Color(1, 0, 1), false, true)
	create_handle_material("handles")

func has_gizmo(spatial) -> bool:
#	var result = spatial is MeshInstance
	var result = spatial is PhysicsBody
#	print("Has custom gizmo " + str(result))
	return result

func redraw(gizmo):
	if !bShow:
		return
	_draw_box_grid(gizmo)

func _draw_box_grid(gizmo):
	gizmo.clear()
	
	var spatial:Spatial = gizmo.get_spatial_node()
#	var targetSize:Vector3 = Vector3(1, 1, 1)
	var targetSize:Vector3 = spatial.scale
#	targetSize.x += 1
#	targetSize.y += 1
#	targetSize.z += 1
	
	var scl:Vector3 = Vector3(1, 1, 1) / spatial.scale
	var size:Vector3 = targetSize * scl
	var radius = size / 2
	
	var _min:Vector3 = radius * -1
	
	var lines = PoolVector3Array()
	
	#####################################
	# centre widget - extends of object from inside - not really useful
	# draw infront doesn't work
	#####################################
	lines.push_back(Vector3(0, radius.y, 0))
	lines.push_back(Vector3(0, -radius.y, 0))
	
	lines.push_back(Vector3(-radius.x, 0, 0))
	lines.push_back(Vector3(radius.x, 0, 0))

	lines.push_back(Vector3(0, 0, -radius.z))
	lines.push_back(Vector3(0, 0, radius.z))
	
	#####################################
	# lines out from centre
	#####################################
	if _drawCentre:
		# x
		lines.push_back(Vector3(-radius.x - scl.x, radius.y, 0))
		lines.push_back(Vector3(radius.x + scl.x, radius.y, 0))
		
		lines.push_back(Vector3(-radius.x - scl.x, -radius.y, 0))
		lines.push_back(Vector3(radius.x + scl.x, -radius.y, 0))
		
		# y
		lines.push_back(Vector3(radius.x, -radius.y - scl.y, 0))
		lines.push_back(Vector3(radius.x, radius.y + scl.y, 0))
		
		lines.push_back(Vector3(-radius.x, -radius.y - scl.y, 0))
		lines.push_back(Vector3(-radius.x, radius.y + scl.y, 0))
	
		# z
		lines.push_back(Vector3(0, -radius.y, -radius.z - scl.z))
		lines.push_back(Vector3(0, -radius.y, radius.z + scl.z))
		
		lines.push_back(Vector3(0, radius.y, -radius.z - scl.z))
		lines.push_back(Vector3(0, radius.y, radius.z + scl.z))
	
	#####################################
	# edges of block
	#####################################
	if _drawBounds:
			# x
		lines.push_back(Vector3(radius.x + scl.x, radius.y, radius.z))
		lines.push_back(Vector3(-radius.x - scl.x, radius.y, radius.z))
	
		lines.push_back(Vector3(radius.x + scl.x, radius.y, -radius.z))
		lines.push_back(Vector3(-radius.x - scl.x, radius.y, -radius.z))
	
		lines.push_back(Vector3(radius.x + scl.x, -radius.y, radius.z))
		lines.push_back(Vector3(-radius.x - scl.x, -radius.y, radius.z))
	
		lines.push_back(Vector3(-radius.x - scl.x, -radius.y, -radius.z))
		lines.push_back(Vector3(radius.x + scl.x, -radius.y, -radius.z))
	
		# y
		lines.push_back(Vector3(radius.x, radius.y + scl.y, radius.z))
		lines.push_back(Vector3(radius.x, -radius.y - scl.y, radius.z))
	
		lines.push_back(Vector3(radius.x, radius.y + scl.y, -radius.z))
		lines.push_back(Vector3(radius.x, -radius.y - scl.y, -radius.z))
	
		lines.push_back(Vector3(-radius.x, radius.y + scl.y, radius.z))
		lines.push_back(Vector3(-radius.x, -radius.y - scl.y, radius.z))
	
		lines.push_back(Vector3(-radius.x, radius.y + scl.y, -radius.z))
		lines.push_back(Vector3(-radius.x, -radius.y - scl.y, -radius.z))
	
		# z
		lines.push_back(Vector3(-radius.x, -radius.y, radius.z + scl.z))
		lines.push_back(Vector3(-radius.x, -radius.y, -radius.z  - scl.z))
	
		lines.push_back(Vector3(radius.x, -radius.y, radius.z + scl.z))
		lines.push_back(Vector3(radius.x, -radius.y, -radius.z  - scl.z))
	
		lines.push_back(Vector3(-radius.x, radius.y, radius.z + scl.z))
		lines.push_back(Vector3(-radius.x, radius.y, -radius.z  - scl.z))
	
		lines.push_back(Vector3(radius.x, radius.y, radius.z + scl.z))
		lines.push_back(Vector3(radius.x, radius.y, -radius.z  - scl.z))
	
#	lines.push_back(Vector3(10, 20, 10))
#	lines.push_back(Vector3(10, 10, 10))

	var handles = PoolVector3Array()

#	handles.push_back(Vector3(0, 0, 0))
#	handles.push_back(Vector3(0, spatial.my_custom_value, 0))
	handles.push_back(Vector3(0, 3, 0))
	
#	var mat:SpatialMaterial = get_material("main", gizmo)
#	mat.flags_no_depth_test = true
	
	gizmo.add_lines(lines, get_material("main", gizmo), false)
	gizmo.add_handles(handles, get_material("handles", gizmo))


# You should implement the rest of handle-related callbacks
# (get_handle_name(), get_handle_value(), commit_handle()...).
