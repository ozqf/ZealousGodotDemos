@tool
extends EditorScript

# .obj
# v x y z
# vt u v
# vn x y z

# # objects
# o entity1
# usemtl material_name
# f 1/1/1 2/2/1 3/3/1 4/4/1


func _write_test_obj_file() -> String:
	var txt = ""
	txt += "v 0 0 0\n"
	txt += "v 1 0 0\n"
	txt += "v 1 1 0\n"
	txt += "vt 0 0\n"
	txt += "vt 0 1\n"
	txt += "vt 1 1\n"
	txt += "vn 0 0 0"
	txt += "o mesh1\n"
	txt += "f 1/1/0 2/2/0 3/3/0\n"
	return txt

func _run() -> void:
	print("Run builder")
	var txt = _write_test_obj_file()
	var file = FileAccess.open("res://test_08_fog_city/mesh1.obj", FileAccess.WRITE)
	file.store_string(txt)
	pass
