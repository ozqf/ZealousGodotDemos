extends ImmediateGeometry

var _tick:float = 1
var _dead:bool = false
var _origin:Vector3 = Vector3()
var _dest:Vector3 = Vector3()

func spawn(a:Vector3, b:Vector3) -> void:
	print("Trail: " + str(a) + " to " + str(b))
	_origin = a
	_dest = b

func _process(_delta) -> void:
	if (_dead):
		return
	
	_tick -= _delta
	if _tick <= 0:
		_dead = true
		queue_free()
		return
	
	begin(Mesh.PRIMITIVE_LINES)
	set_color(Color(1, 0, 0, 1))
	add_vertex(_origin)
	add_vertex(_dest)
	end()
