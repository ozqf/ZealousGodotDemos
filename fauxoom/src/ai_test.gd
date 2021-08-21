extends Spatial

onready var _body:MeshInstance = $body
onready var _toTarget:Spatial = $to_target
onready var _to_left:Spatial = $to_left
onready var _to_right:Spatial = $to_right

var _mat_green = preload("res://assets/mat_green.tres")
var _mat_red = preload("res://assets/mat_red.tres")

var _tick:float = 0

var _yawDegrees:float = 0

func _ready() -> void:
	# self.set_surface_material(0, _mat_red)
	pass

func _process(_delta:float) -> void:
	var info:Dictionary = Game.get_player_target()
	if info.id == 0:
		return
	var selfPos:Vector3 = global_transform.origin
	var selfForward:Vector3 = -global_transform.basis.z
	var tarForward:Vector3 = info.forward
	# var tarForward:Vector3 = info.flatForward
	var tarPos:Vector3 = info.position
	
	_tick -= _delta
	if _tick <= 0:
		_toTarget.look_at(tarPos, Vector3.UP)
		_tick = 1
	
	_yawDegrees += 45 * _delta
	rotation_degrees = Vector3(0, _yawDegrees, 0)

	var targetIsToLeft:bool = ZqfUtils.is_point_left_of_line3D_flat(selfPos, selfForward, tarPos)
	var targetAimIsToLeft:bool = ZqfUtils.is_point_left_of_line3D_flat(tarPos, tarForward, selfPos)
	
	if targetIsToLeft:
		_to_left.visible = true
		_to_right.visible = false
	else:
		_to_left.visible = false
		_to_right.visible = true

	if targetAimIsToLeft:
		_body.set_surface_material(0, _mat_red)
	else:
		_body.set_surface_material(0, _mat_green)
