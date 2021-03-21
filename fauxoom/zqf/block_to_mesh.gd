extends Spatial

export var wallMaterial:SpatialMaterial = null
export var groundMaterial:SpatialMaterial = null
export var ceilingMaterial:SpatialMaterial = null

export var buildOnStart:bool = true

var groundMesh = null
var ceilingMesh = null
var sidesMesh = null

func _ready() -> void:
	groundMesh = MeshInstance.new()
	groundMesh.script = load("res://zqf/mesh_generator.gd")
	add_child(groundMesh)
	groundMesh.set_material(groundMaterial)
	
	ceilingMesh = MeshInstance.new()
	ceilingMesh.script = load("res://zqf/mesh_generator.gd")
	add_child(ceilingMesh)
	ceilingMesh.set_material(ceilingMaterial)
	
	sidesMesh = MeshInstance.new()
	sidesMesh.script = load("res://zqf/mesh_generator.gd")
	add_child(sidesMesh)
	sidesMesh.set_material(wallMaterial)
	
	if buildOnStart:
		_build()

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

func _build() -> void:
	var volumesNode = get_node("volumes")
	var numVolumes:int = volumesNode.get_child_count()
	
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
		var uvSEx:Vector2 = Vector2(1.0 * scaleX, 0.0)
		var uvSEz:Vector2 = Vector2(1.0 * scaleZ, 0.0)

		var uvNExz:Vector2 = Vector2(1.0 * scaleX, 1.0 * scaleZ)
		var uvNExy:Vector2 = Vector2(1.0 * scaleX, 1.0 * scaleY)
		var uvNEzz:Vector2 = Vector2(1.0 * scaleZ, 1.0 * scaleZ)
		var uvNEzy:Vector2 = Vector2(1.0 * scaleZ, 1.0 * scaleY)

		var uvNWz:Vector2 = Vector2(0.0, 1.0 * scaleZ)
		var uvNWy:Vector2 = Vector2(0.0, 1.0 * scaleY)

		# top
		groundMesh.add_triangle_v(tris[3], tris[7], tris[1], uvSW, uvNExz, uvSEx)
		groundMesh.add_triangle_v(tris[3], tris[5], tris[7], uvSW, uvNWz, uvNExz)
		
		# bottom
		ceilingMesh.add_triangle_v(tris[6], tris[2], tris[4], uvSW, uvNExz, uvSEx)
		ceilingMesh.add_triangle_v(tris[6], tris[0], tris[2], uvSW, uvNWz, uvNExz)
		
		# front
		sidesMesh.add_triangle_v(tris[0], tris[1], tris[2], uvSW, uvNExy, uvSEx)
		sidesMesh.add_triangle_v(tris[0], tris[3], tris[1], uvSW, uvNWy, uvNExy)
		
		# left
		sidesMesh.add_triangle_v(tris[2], tris[7], tris[4], uvSW, uvNEzy, uvSEz)
		sidesMesh.add_triangle_v(tris[2], tris[1], tris[7], uvSW, uvNWy, uvNEzy)
#		
		# back
		sidesMesh.add_triangle_v(tris[4], tris[5], tris[6], uvSW, uvNExy, uvSEx)
		sidesMesh.add_triangle_v(tris[4], tris[7], tris[5], uvSW, uvNWy, uvNExy)
		
		# right
		sidesMesh.add_triangle_v(tris[6], tris[3], tris[0], uvSW, uvNEzy, uvSEz)
		sidesMesh.add_triangle_v(tris[6], tris[5], tris[3], uvSW, uvNWy, uvNEzy)
		
	if groundMaterial != null:
		groundMesh.set_material(groundMaterial)
	groundMesh.end_mesh()
	ceilingMesh.end_mesh()
	sidesMesh.end_mesh()
