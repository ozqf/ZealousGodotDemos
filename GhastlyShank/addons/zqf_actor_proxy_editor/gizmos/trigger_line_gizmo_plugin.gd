extends EditorNode3DGizmoPlugin

func _get_gizmo_name():
	return "TriggerLineGizmoPlugin"

func _has_gizmo(node):
	if node.has_method("get_actor_proxy_info"):
		return true
	return false

func _init():
	create_material("main", Color(1, 0, 1), false, true)
	#create_handle_material("handles")
	var mat:StandardMaterial3D = get_material("main")
	

func _redraw(gizmo:EditorNode3DGizmo):
	print("Draw trigger lines")
	gizmo.clear()
	var node:Node3D = gizmo.get_node_3d()
	
	var others:Array = ZqfActorProxyEditor.find_trigger_target_positions(node)
	var lines = PackedVector3Array()
	
	var globalPos:Vector3 = node.global_position
	var scale:Vector3 = node.scale
	
	for other in others:
		if other == node:
			continue
		var a:Vector3 = Vector3()
		var b = other.global_position - globalPos
		a += Vector3(0, 0.5, 0)
		b += Vector3(0, 0.5, 0)
		
		# gizmos scales to the node, so we need to counteract that 
		a *= (Vector3.ONE / node.scale)
		b *= (Vector3.ONE / node.scale)
		
		lines.push_back(a)
		lines.push_back(b)
	
#	lines.push_back(Vector3(0, 0, 0))
#	var dx:float = randf_range(-5, 5)
#	var dy:float = randf_range(-5, 5)
#	var dz:float = randf_range(-5, 5)
#	lines.push_back(Vector3(dx, dy, dz))
	gizmo.add_lines(lines, get_material("main", gizmo), false)
