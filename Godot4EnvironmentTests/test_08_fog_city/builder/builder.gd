@tool
extends EditorScript

static func example_tiles() -> String:
	var txt = ""
	txt += "0001\n"
	txt += "0100\n"
	txt += "1010\n"
	txt += "0110\n"
	txt += "0011\n"
	txt += "1011\n"
	return txt

#region obj output
# .obj
# v x y z
# vt u v
# vn x y z

# # objects
# o entity1
# usemtl material_name
# f 1/1/1 2/2/1 3/3/1 4/4/1

func create_face() -> PackedVector3Array:
	var f:PackedVector3Array = PackedVector3Array()
	return f

static func key_to_v3(key:String) -> Vector3:
	var v:Vector3 = Vector3()
	var tokens:PackedStringArray = key.split(",")
	var numTokens:int = tokens.size()
	if numTokens > 0:
		v.x = float(tokens[0])
	if numTokens > 1:
		v.y = float(tokens[1])
	if numTokens > 2:
		v.z = float(tokens[2])
	return v

static func v3_to_key(v:Vector3) -> String:
	return str(v.x) + "," + str(v.y) + "," + str(v.z)

static func add_v3_to_store(store:PackedVector3Array, v:Vector3) -> int:
	var num:int = store.size()
	for i in range(0, num):
		var candidate:Vector3 = store[i]
		if candidate.is_equal_approx(v):
			return i
	store.push_back(v)
	return num

static func add_v2_to_store(store:PackedVector2Array, v:Vector2) -> int:
	var num:int = store.size()
	for i in range(0, num):
		var candidate:Vector2 = store[i]
		if candidate.is_equal_approx(v):
			return i
	store.push_back(v)
	return num

func add_vert_to_face(f:PackedVector3Array, v:Vector3, uv:Vector2, n:Vector3) -> void:
	f.push_back(v)
	f.push_back(Vector3(uv.x, uv.y, 0))
	f.push_back(n)

func _create_test_face() -> PackedVector3Array:
	var f:PackedVector3Array = create_face()
	var n:Vector3 = Vector3()
	add_vert_to_face(f, Vector3(0, 0, 0), Vector2(0, 0), n)
	add_vert_to_face(f, Vector3(1, 0, 0), Vector2(1, 0), n)
	add_vert_to_face(f, Vector3(1, 1, 0), Vector2(1, 1), n)
	return f

func _write_test_obj_file_2() -> String:
	var verts:PackedVector3Array = PackedVector3Array()
	var uvs:PackedVector2Array = PackedVector2Array()
	var normals:PackedVector3Array = PackedVector3Array()
	
	var faces:Array[PackedInt32Array] = []
	var f:PackedInt32Array
	f = PackedInt32Array()
	var x:float = 0.0
	var y:float = 0.0
	# vert 1
	f.push_back(add_v3_to_store(verts, Vector3(x, y, 0)))
	f.push_back(add_v2_to_store(uvs, Vector2(x, y)))
	f.push_back(add_v3_to_store(normals, Vector3(x, y, 1)))
	# vert 2
	f.push_back(add_v3_to_store(verts, Vector3(x + 1, y, 0)))
	f.push_back(add_v2_to_store(uvs, Vector2(x + 1, y)))
	f.push_back(add_v3_to_store(normals, Vector3(x, y, 1)))
	# vert 3
	f.push_back(add_v3_to_store(verts, Vector3(x + 1, y + 1, 0)))
	f.push_back(add_v2_to_store(uvs, Vector2(x + 1, y + 1)))
	f.push_back(add_v3_to_store(normals, Vector3(x, y, 1)))
	# vert 4
	f.push_back(add_v3_to_store(verts, Vector3(x, y + 1, 0)))
	f.push_back(add_v2_to_store(uvs, Vector2(x, y + 1)))
	f.push_back(add_v3_to_store(normals, Vector3(x, y, 1)))
	faces.push_back(f)
	
	f = PackedInt32Array()
	x = 2.0
	# vert 1
	f.push_back(add_v3_to_store(verts, Vector3(x, y, 0)))
	f.push_back(add_v2_to_store(uvs, Vector2(x, y)))
	f.push_back(add_v3_to_store(normals, Vector3(x, y, 1)))
	# vert 2
	f.push_back(add_v3_to_store(verts, Vector3(x + 1, y, 0)))
	f.push_back(add_v2_to_store(uvs, Vector2(x + 1, y)))
	f.push_back(add_v3_to_store(normals, Vector3(x, y, 1)))
	# vert 3
	f.push_back(add_v3_to_store(verts, Vector3(x + 1, y + 1, 0)))
	f.push_back(add_v2_to_store(uvs, Vector2(x + 1, y + 1)))
	f.push_back(add_v3_to_store(normals, Vector3(x, y, 1)))
	# vert 4
	f.push_back(add_v3_to_store(verts, Vector3(x, y + 1, 0)))
	f.push_back(add_v2_to_store(uvs, Vector2(x, y + 1)))
	f.push_back(add_v3_to_store(normals, Vector3(x, y, 1)))
	faces.push_back(f)
	var txt = ""
	
	for i in range(0, verts.size()):
		var v:Vector3 = verts[i]
		txt += "v " + str(v.x) + " " + str(v.y) + " " + str(v.z) + "\n"
	txt += "\n"
	for i in range(0, uvs.size()):
		var uv:Vector2 = uvs[i]
		txt += "vt " + str(uv.x) + " " + str(uv.y) + "\n"
	txt += "\n"
	for i in range(0, normals.size()):
		var n:Vector3 = normals[i]
		txt += "vn " + str(n.x) + " " + str(n.y) + " " + str(n.z) + "\n"
	txt += "\n"
	
	txt += "o mesh1\n"
	var numFaces:int = faces.size()
	for i in range(0, numFaces):
		f = faces[i]
		var faceSize:int = f.size()
		if faceSize % 3 != 0:
			print("Aborted: Invalid face array length: " + str(faceSize))
			return ""
		var j:int = 0
		txt += "f "
		while j < faceSize:
			txt += str(f[j] + 1)
			txt += "/"
			txt += str(f[j + 1] + 1)
			txt += "/"
			txt += str(f[j + 2] + 1)
			txt += " "
			j += 3
		txt += "\n"
	return txt

func _write_test_obj_file_1() -> String:
	var txt = ""
	txt += "v 0 0 0\n"
	txt += "v 1 0 0\n"
	txt += "v 1 1 0\n"
	txt += "v 0 1 0\n"
	txt += "vt 0 0\n"
	txt += "vt 0 1\n"
	txt += "vt 1 1\n"
	txt += "vt 1 0\n"
	txt += "vn 0 0 0\n"
	txt += "o mesh1\n"
	txt += "f 1/1/1 2/2/1 3/3/1 4/4/1\n"
	return txt

func write_obj_txt(path:String, txt:String) -> void:
	print("Writing " + str(txt.length()) + " chars to " + str(path))
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(txt)

#endregion

func _run() -> void:
	print("Run builder " + str(Time.get_date_string_from_system()) + "T" + str(Time.get_time_string_from_system()))
	var source:String = example_tiles()
	print(source)
	var txt:String = _write_test_obj_file_2()
	if txt == null || txt == "":
		print("Aborted")
		return
	print(txt)
	write_obj_txt("res://test_08_fog_city/mesh1.obj", txt)
