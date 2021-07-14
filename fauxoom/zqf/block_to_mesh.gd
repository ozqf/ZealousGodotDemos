extends Spatial

export var pixelsPerMetre:int = 64
export var buildOnStart:bool = true
export var verbose:bool = false

export var wallMaterial:SpatialMaterial = null
export var groundMaterial:SpatialMaterial = null
export var ceilingMaterial:SpatialMaterial = null

var groundMesh = null
var ceilingMesh = null
var sidesMesh = null

var _groundTexSize:Vector2 = Vector2(32, 32)
var _wallTexSize:Vector2 = Vector2(32, 32)
var _ceilingTexSize:Vector2 = Vector2(32, 32)

func _ready() -> void:
	if verbose:
		print("--- Block 2 mesh ready ---")
	groundMesh = MeshInstance.new()
	groundMesh.script = load("res://zqf/mesh_generator.gd")
	add_child(groundMesh)
	if groundMaterial != null:
		if verbose:
			print("Set ground material: " + groundMaterial.resource_path)
		groundMesh.set_material(groundMaterial)
		_groundTexSize.x = groundMaterial.albedo_texture.get_width()
		_groundTexSize.y = groundMaterial.albedo_texture.get_height()
		print("ground tex size: " + str(_groundTexSize.x) + ", " + str(_groundTexSize.y))
	
	ceilingMesh = MeshInstance.new()
	ceilingMesh.script = load("res://zqf/mesh_generator.gd")
	add_child(ceilingMesh)
	if ceilingMaterial != null:
		if verbose:
			print("Set ceiling material: " + ceilingMaterial.resource_path)
		ceilingMesh.set_material(ceilingMaterial)
		_ceilingTexSize.x = ceilingMaterial.albedo_texture.get_width()
		_ceilingTexSize.y = ceilingMaterial.albedo_texture.get_height()
		print("ceiling tex size: " + str(_ceilingTexSize.x) + ", " + str(_ceilingTexSize.y))
	
	sidesMesh = MeshInstance.new()
	sidesMesh.script = load("res://zqf/mesh_generator.gd")
	add_child(sidesMesh)
	if wallMaterial != null:
		if verbose:
			print("Set wall material: " + wallMaterial.resource_path)
		sidesMesh.set_material(wallMaterial)
		_wallTexSize.x = wallMaterial.albedo_texture.get_width()
		_wallTexSize.y = wallMaterial.albedo_texture.get_height()
		print("wall tex size: " + str(_wallTexSize.x) + ", " + str(_wallTexSize.y))
	
	if buildOnStart:
		build()

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

func gather_nodes(root:Spatial, resultsArray) -> void:
	var numChildren:int = root.get_child_count()
	if numChildren == 0:
		resultsArray.push_back(root)
		return
	for _i in range(0, numChildren):
		gather_nodes(root.get_child(_i), resultsArray)

func build() -> void:
	# var volumesNode = get_node("volumes")
	if verbose:
		print("--- Block 2 mesh build ---")
	var volumes = []
	if has_node("volumes"):
		gather_nodes(get_node("volumes"), volumes)
	else:
		gather_nodes(self, volumes)
	var numVolumes:int = volumes.size()
	# var numVolumes:int = volumesNode.get_child_count()
	if verbose:
		print("B2Mesh found " + str(numVolumes) + " volumes")
	
	groundMesh.start_mesh()
	ceilingMesh.start_mesh()
	sidesMesh.start_mesh()

	var triSize:float = 0.5

	for _i in range(0, numVolumes):
		# var child:Spatial = volumesNode.get_child(_i)
		var child:Spatial = volumes[_i]
		if verbose:
			print("Adding volume " + str(_i) + ": " + child.name)
		child.visible = false
		var t:Transform = child.global_transform
		var pos:Vector3 = t.origin
		var rot:Basis = t.basis
		
		var tris = _cube_tris(triSize)
		# transform
		for _j in range(0, tris.size()):
			tris[_j] = rot.xform(tris[_j]) + pos
		

		# TODO - a proper pixels-per-metre implementation here!
		
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
		
	# if groundMaterial != null:
	# 	groundMesh.set_material(groundMaterial)
	groundMesh.end_mesh()
	ceilingMesh.end_mesh()
	sidesMesh.end_mesh()
