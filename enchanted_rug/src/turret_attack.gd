extends Spatial

var _projectile_t = preload("res://prefabs/projectiles/prj_ball_large.tscn")
var _column_projectile_t = preload("res://prefabs/projectiles/prj_column.tscn")

enum ProjectileType {
	Point = 0,
	Small = 1,
	Large = 2,
	Column = 3
}

export var targetName:String = ""
export(ProjectileType) var projectileType = ProjectileType.Point
export var refireRate:float = 1
export var projectileRoll:float = 0
export var projectileRollRate:float = 0
export var alternateRoll:bool = false

var _active:bool = false
var _refireTick:float = 0
var _rollDir:float = 1

func _ready() -> void:
	add_to_group(Main.GROUP_NAME)

func game_trigger(triggerTargetName:String) -> void:
	if targetName != "" && targetName == triggerTargetName:
		_active = !_active

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
		_refireTick = refireRate
		_fire(forward, 0, projectileRollRate * _rollDir)
#		_fire(forward, 45, projectileRollRate * _rollDir)
#		_fire(forward, 90, projectileRollRate * _rollDir)
#		_fire(forward, 135, projectileRollRate * _rollDir)
		
		if alternateRoll:
			_rollDir *= -1
		
		# _fire_offset(-5000, 0)
		# _fire_offset(5000, 0)
		# var offset:Vector3 = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, 5000, 0)
		# _fire(offset)

		# offset = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, -5000, 0)
		# _fire(offset)
	else:
		_refireTick -= _delta
