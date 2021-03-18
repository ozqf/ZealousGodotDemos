extends Spatial

onready var groundMesh = $mesh_ground
onready var ceilingMesh = $mesh_ceiling
onready var sidesMesh = $mesh_sides

export var groundMaterial:SpatialMaterial = null

func _cube_tris(size:float) -> PoolVector3Array:
	var tris:PoolVector3Array = PoolVector3Array()
	
	# front quad
	tris.push_back(Vector3(-size, -size, size))
	tris.push_back(Vector3(size, size, size))
	tris.push_back(Vector3(size, -size, size))
	tris.push_back(Vector3(-size, size, size))

	# back quad
	tris.push_back(Vector3(size, -size, -size))
	tris.push_back(Vector3(-size, size, -size))
	tris.push_back(Vector3(-size, -size, -size))
	tris.push_back(Vector3(size, size, -size))

	return tris

func _ready() -> void:
	_build()
	
func _build() -> void:
	var volumesNode = get_node("volumes")
	var numVolumes:int = volumesNode.get_child_count()
	print("Block 2 mesh found " + str(numVolumes) + " volumes")

	groundMesh.start_mesh()
	ceilingMesh.start_mesh()
	sidesMesh.start_mesh()

	var triSize:float = 0.5

	for _i in range(0, numVolumes):
		var child:Spatial = volumesNode.get_child(_i)
		child.visible = false
		var t:Transform = child.global_transform
		var pos:Vector3 = t.origin
		var rot:Basis = t.basis
		print(str(t.origin))

		var tris = _cube_tris(triSize)
		# transform
		for _j in range(0, tris.size()):
			tris[_j] = rot.xform_inv(tris[_j]) + pos
		
		# scale UVs to tile over tris
		# scale is already applied to verts by basis xform
		# divide by 2 for more than 1 texture per metre
		# for a 'down-res' look
		var scaleX = rot.x.length() / 2
		var scaleY = rot.y.length() / 2
		var scaleZ = rot.z.length() / 2

		var uvSW:Vector2 = Vector2(0.0, 0.0)
		var uvSE:Vector2 = Vector2(1.0 * scaleX, 0.0)

		var uvNEz:Vector2 = Vector2(1.0 * scaleX, 1.0 * scaleZ)
		var uvNEy:Vector2 = Vector2(1.0 * scaleX, 1.0 * scaleY)
		var uvNWz:Vector2 = Vector2(0.0, 1.0 * scaleZ)
		var uvNWy:Vector2 = Vector2(0.0, 1.0 * scaleY)

		# top
		groundMesh.add_triangle_v(tris[3], tris[7], tris[1], uvSW, uvNEz, uvSE)
		groundMesh.add_triangle_v(tris[3], tris[5], tris[7], uvSW, uvNWz, uvNEz)
		
		# bottom
		ceilingMesh.add_triangle_v(tris[6], tris[2], tris[4], uvSW, uvNEz, uvSE)
		ceilingMesh.add_triangle_v(tris[6], tris[0], tris[2], uvSW, uvNWz, uvNEz)
		
		# front
		sidesMesh.add_triangle_v(tris[0], tris[1], tris[2], uvSW, uvNEy, uvSE)
		sidesMesh.add_triangle_v(tris[0], tris[3], tris[1], uvSW, uvNWy, uvNEy)
		
		# left
		sidesMesh.add_triangle_v(tris[2], tris[7], tris[4], uvSW, uvNEy, uvSE)
		sidesMesh.add_triangle_v(tris[2], tris[1], tris[7], uvSW, uvNWy, uvNEy)
		
		# back
		sidesMesh.add_triangle_v(tris[4], tris[5], tris[6], uvSW, uvNEy, uvSE)
		sidesMesh.add_triangle_v(tris[4], tris[7], tris[5], uvSW, uvNWy, uvNEy)
		
		# right
		sidesMesh.add_triangle_v(tris[6], tris[3], tris[0], uvSW, uvNEy, uvSE)
		sidesMesh.add_triangle_v(tris[6], tris[5], tris[3], uvSW, uvNWy, uvNEy)
		
	if groundMaterial != null:
		groundMesh.set_material(groundMaterial)
	groundMesh.end_mesh()
	ceilingMesh.end_mesh()
	sidesMesh.end_mesh()


func _build_old() -> void:
	var volumesNode = get_node("volumes")
	var numVolumes:int = volumesNode.get_child_count()
	print("Block 2 mesh found " + str(numVolumes) + " volumes")	

	groundMesh.start_mesh()
	var triSize:float = 0.5

	var tris = _cube_tris(triSize)

	for _i in range(0, numVolumes):
		var child:Spatial = volumesNode.get_child(_i)
		child.visible = false
		var t:Transform = child.global_transform
		var pos:Vector3 = t.origin
		var rot:Basis = t.basis
		print(str(t.origin))

		var v0:Vector3 = Vector3(-triSize, triSize, triSize)
		var v1:Vector3 = Vector3(triSize, triSize, -triSize)
		var v2:Vector3 = Vector3(triSize, triSize, triSize)

		v0 = rot.xform_inv(v0)
		v1 = rot.xform_inv(v1)
		v2 = rot.xform_inv(v2)

		v0 += pos
		v1 += pos
		v2 += pos
		
		# scale is already applied to verts by basis xform
		var scaleX = rot.x.length()
		var scaleY = rot.y.length()
		var scaleZ = rot.z.length()

		var uvSW:Vector2 = Vector2(0.0, 0.0)
		var uvNE:Vector2 = Vector2(1.0 * scaleX, 1.0 * scaleZ)
		var uvSE:Vector2 = Vector2(1.0 * scaleX, 0.0)
		var uvNW:Vector2 = Vector2(0.0, 1.0 * scaleX)

		groundMesh.add_triangle_v(v0, v1, v2, uvSW, uvNE, uvSE)
	
	if groundMaterial != null:
		groundMesh.set_material(groundMaterial)
	groundMesh.end_mesh()
