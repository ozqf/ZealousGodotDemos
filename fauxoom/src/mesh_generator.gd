extends MeshInstance
class_name MeshGenerator

var _built:bool = false
var _building:bool = false
# constructed mesh
var _sTool:SurfaceTool = SurfaceTool.new()
var _tmpMesh = Mesh.new()
var _vertices = PoolVector3Array()
var _uvs = PoolVector2Array()
var _mat = SpatialMaterial.new()
var _colour = Color(0.9, 0.1, 0.1)

func set_material(newMat:SpatialMaterial) -> void:
	self.set_material_override(newMat)

func start_mesh() -> void:
	if _built || _building:
		return
	print("Start mesh gen")
	_building = true
	_sTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	_sTool.set_material(_mat)

func end_mesh() -> void:
	if _built || !_building:
		return
	print("End mesh gen")
	_building = false
	_built = true
	_sTool.commit(_tmpMesh)
	self.mesh = _tmpMesh

# anti-clockwise vertex winding
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

func add_triangle_v(v1:Vector3, v2:Vector3, v3:Vector3, uv1:Vector2, uv2:Vector2, uv3:Vector2) -> void:
	if !_building:
		return
	_sTool.add_colour(_colour)
	_sTool.add_uv(uv1)
	_sTool.add_vertex(v1)
	_sTool.add_colour(_colour)
	_sTool.add_uv(uv2)
	_sTool.add_vertex(v2)
	_sTool.add_colour(_colour)
	_sTool.add_uv(uv3)
	_sTool.add_vertex(v3)
