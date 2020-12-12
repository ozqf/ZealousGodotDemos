extends Spatial

var _camera:Camera = null
var _emptyTrans:Transform = Transform.IDENTITY

func set_camera(cam:Camera) -> void:
	if cam == null:
		return
	_camera = cam

func clear_camera(cam:Camera) -> void:
	if cam != null && _camera == cam:
		_camera = null

func get_camera_pos() -> Transform:
	if _camera != null:
		return _camera.global_transform
	return _emptyTrans
