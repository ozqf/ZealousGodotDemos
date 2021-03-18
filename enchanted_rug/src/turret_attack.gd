extends Spatial

var _projectile_t = preload("res://prefabs/projectiles/prj_ball_large.tscn")
var _column_projectile_t = preload("res://prefabs/projectiles/prj_column.tscn")

var _active:bool = true

var _refireTick:float = 0
var _spinDir:float = 1
export var refireRate:float = 1

func _ready() -> void:
	add_to_group(Console.GROUP)

func _fire(forward:Vector3, _spinStart:float = 0, _spinRate:float = 0) -> void:
	var pos:Vector3 = global_transform.origin

	# var prj = _projectile_t.instance()
	var prj = _column_projectile_t.instance()

	get_tree().get_current_scene().add_child(prj)
	prj.launch(pos, forward, _spinStart, _spinRate)

func _fire_offset(spreadX:float, spreadY:float, _spinStart:float = 0, _spinRate:float = 0) -> void:
	var t:Transform = global_transform
	var offset:Vector3 = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, spreadX, spreadY)
	_fire(offset)

func _process(_delta:float) -> void:
	if !_active:
		return
	var tar:Dictionary = Main.get_target()
	if tar.valid == false:
		return
	look_at(tar.position, Vector3.UP)

	var t:Transform = global_transform
	var forward:Vector3 = -t.basis.z

	if _refireTick <= 0:
		_spinDir *= -1
		_refireTick = refireRate
		_fire(forward, 0, 22.5 * _spinDir)
		_fire(forward, 45, 22.5 * _spinDir)
		_fire(forward, 90, 22.5 * _spinDir)
		_fire(forward, 135, 22.5 * _spinDir)
		
		# _fire_offset(-5000, 0)
		# _fire_offset(5000, 0)
		# var offset:Vector3 = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, 5000, 0)
		# _fire(offset)

		# offset = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, -5000, 0)
		# _fire(offset)
	else:
		_refireTick -= _delta
