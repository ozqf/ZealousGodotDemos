extends Spatial

var _projectile_t = preload("res://prefabs/projectiles/prj_ball_large.tscn")

var _active:bool = true

var _refireTick:float = 0

func _fire() -> void:
	var pos:Vector3 = global_transform.origin
	var forward:Vector3 = -global_transform.basis.z
	var prj = _projectile_t.instance()
	get_tree().get_current_scene().add_child(prj)
	prj.launch(pos, forward)

func _process(_delta:float) -> void:
	if !_active:
		return
	var tar:Dictionary = Main.get_target()
	if tar.valid == false:
		return
	look_at(tar.position, Vector3.UP)

	if _refireTick <= 0:
		_refireTick = 0.1
		_fire()
	else:
		_refireTick -= _delta
