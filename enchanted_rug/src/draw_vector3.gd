extends ImmediateGeometry

var _varDict:Dictionary = { }
var _varName:String = ""
var _scale:float = 1
var _colour:Color = Color.green

func init(varDict:Dictionary, varName, newColour:Color, scale:float) -> void:
	_varDict= varDict
	_varName = varName
	_colour = newColour
	_scale = scale

func draw(v:Vector3, basis:Basis) -> void:
	var vLen:float = v.length()
	var dir:Vector3 = v.normalized()
	var parentRot:Basis = basis
	dir = parentRot.xform_inv (dir)
	# v = dir
	v = dir * vLen
	clear()
	begin(Mesh.PRIMITIVE_LINES, null)
	set_color(_colour)
	add_vertex(Vector3(0, 0, 0))
	add_vertex(Vector3(v.x * _scale, v.y * _scale, v.z * _scale))
	end()

func _process(_delta:float) -> void:
	if _varName == "":
		return
	var v:Vector3 = _varDict[_varName]
	draw(v, get_parent().global_transform.basis)
	
