extends MeshInstance
class_name MeshGenerator

const defaultColour:Color = Color(1, 1, 1)

export var verbose:bool = false
export var material:SpatialMaterial = SpatialMaterial.new()

var _built:bool = false
var _building:bool = false
# constructed mesh
var _sTool:SurfaceTool = SurfaceTool.new()
var _tmpMesh = Mesh.new()
var _vertices = PoolVector3Array()
#var _uvs = PoolVector2Array()
var _colour = defaultColour

func set_next_colour(newColour:Color) -> void:
	_colour = newColour

func reset_next_colour() -> void:
	_colour = defaultColour

func clear() -> void:
	# print("Clearing " + str(_vertices.size()) + " verts")
	_sTool.clear()
	_tmpMesh = Mesh.new()
	_built = false
	_building = false
	_vertices = []
	mesh = null

func set_material(newMat:SpatialMaterial) -> void:
	material = newMat
	self.set_material_override(newMat)

func get_collision_mesh() -> Shape:
	if _vertices.size() == 0:
		return null
	var poly:ConcavePolygonShape = ConcavePolygonShape.new()
	poly.set_faces(_vertices)
	return poly

func start_mesh() -> void:
	if _built || _building:
		print("Cannot start mesh, already building/built!")
		return
	if verbose:
		print("Start mesh gen")
	_building = true
	_sTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	_sTool.set_material(material)

func end_mesh() -> void:
	if _built || !_building:
		return
	if verbose:
		print("End mesh gen")
	
	_building = false
	_built = true
	# print("Commit mesh with " + str(_vertices.size()) + " verts")
	if _vertices.size() == 0:
		self.mesh = null
		return
	var _foo = _sTool.commit(_tmpMesh)
	self.mesh = _tmpMesh

# clockwise vertex winding!
func add_triangle(v1X:float, v1Y:float, v1Z:float, v2X:float, v2Y:float, v2Z:float, v3X:float, v3Y:float, v3Z:float, uv1X:float, uv1Y:float, uv2X:float, uv2Y:float, uv3X:float, uv3Y:float) -> void:
	if !_building:
		return
	_sTool.add_color(_colour)
	_sTool.add_uv(Vector2(uv1X, uv1Y))
	_sTool.add_vertex(Vector3(v1X, v1Y, v1Z))
	
	_sTool.add_color(_colour)
	_sTool.add_uv(Vector2(uv2X, uv2Y))
	_sTool.add_vertex(Vector3(v2X, v2Y, v2Z))
	
	_sTool.add_color(_colour)
	_sTool.add_uv(Vector2(uv3X, uv3Y))
	_sTool.add_vertex(Vector3(v3X, v3Y, v3Z))
	
	_vertices.push_back(v1X, v1Y, v1Z)
	_vertices.push_back(v2X, v2Y, v2Z)
	_vertices.push_back(v3X, v3Y, v3Z)

# clockwise vertex winding!
func add_triangle_v(v1:Vector3, v2:Vector3, v3:Vector3, uv1:Vector2, uv2:Vector2, uv3:Vector2) -> void:
	if !_building:
		return
	
	# _colour = Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1), 1)
	_colour = Color.white
	_sTool.add_color(_colour)
	_sTool.add_uv(uv1)
	_sTool.add_vertex(v1)
	
	_sTool.add_color(_colour)
	_sTool.add_uv(uv2)
	_sTool.add_vertex(v2)
	_sTool.add_color(_colour)
	_sTool.add_uv(uv3)
	_sTool.add_vertex(v3)
	
	_vertices.push_back(v1)
	_vertices.push_back(v2)
	_vertices.push_back(v3)

func _create_test_mesh() -> void:
	if verbose:
		print("Run world mesh gen")
	self.start_mesh()
	#self.add_triangle(Vector3(-50, 0, 0), Vector3(50, 0, 0), Vector3(50, 50, 50), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1))
	self.add_triangle(-50, 0, 0,  50, 0, 0,  50, 50, 0,  0, 1,  1, 1,  1, 0)
	
	self.add_triangle(-50, 0, 0,  50, 50, 0,  -50, 50, 0,  0, 1,  1, 0,  0, 0)
	self.end_mesh()
