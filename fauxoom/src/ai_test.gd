extends MeshInstance

var _mat_green = preload("res://assets/mat_green.tres")
var _mat_red = preload("res://assets/mat_red.tres")

func _ready() -> void:
	self.set_surface_material(0, _mat_red)

func _process(_delta:float) -> void:
	var info:Dictionary = Game.get_player_target()
	if info.id == 0:
		return
	var selfPos:Vector3 = global_transform.origin
	var tarForward:Vector3 = info.flatForward
	var tarPos:Vector3 = info.position
	var isLeft:bool = ZqfUtils.is_point_left_of_line3D_flat(tarPos, tarForward, selfPos)
	if isLeft:
		self.set_surface_material(0, _mat_red)
	else:
		self.set_surface_material(0, _mat_green)
