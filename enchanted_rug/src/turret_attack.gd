extends Spatial

var _point_projectile_t = preload("res://prefabs/projectiles/projectile.tscn")
var _large_projectile_t = preload("res://prefabs/projectiles/prj_ball_large.tscn")
var _column_projectile_t = preload("res://prefabs/projectiles/prj_column.tscn")
var _artillery_column_projectile_t = preload("res://prefabs/projectiles/prj_artillery_column.tscn")
var _flak_projectile_t = preload("res://prefabs/projectiles/prj_flak.tscn")
var _missile_t = preload("res://prefabs/projectiles/prj_missile.tscn")

enum ProjectileType {
	Point,				# 0
	Column,				# 1
	Small,				# 2
	Large,				# 3
	ArtilleryColumn,	# 4
	Flak,				# 5
	Missile				# 6
}

export var targetName:String = ""
export(ProjectileType) var projectileType = ProjectileType.Point
export var refireRate:float = 1
# export var projectileRoll:float = 0
export var projectileRollRate:float = 0
export var alternateRoll:bool = false
export var ignoreAimX:bool = false
export var ignoreAimY:bool = false
export var ignoreAimZ:bool = false

var _active:bool = false
var _refireTick:float = 0
var _rollDir:float = 1
var _prjInfo:PrjLaunchInfo = null

var _aimForward:Vector3 = Vector3()

func _ready() -> void:
	add_to_group(Main.GROUP_NAME)
	_prjInfo = Main.new_prj_info()

func game_trigger(triggerTargetName:String) -> void:
	if targetName != "" && targetName == triggerTargetName:
		_active = !_active
	
func set_active(flag:bool) -> void:
	_active = flag

func _fire_projectile(prjInfo:PrjLaunchInfo) -> void:
	#var pos:Vector3 = global_transform.origin

	var prj
	if projectileType == ProjectileType.Column:
		prj = _column_projectile_t.instance()
	elif projectileType == ProjectileType.Large:
		prj = _large_projectile_t.instance()
	elif projectileType == ProjectileType.ArtilleryColumn:
		prj = _artillery_column_projectile_t.instance()
	elif projectileType == ProjectileType.Flak:
		prj = _flak_projectile_t.instance()
	elif projectileType == ProjectileType.Missile:
		prj = _missile_t.instance()
	else:
		prj = _point_projectile_t.instance()
	if has_node("ProjectileMovement") && prj.has_method("copy_settings"):
		prj.copy_settings($ProjectileMovement)
	
	get_tree().get_current_scene().add_child(prj)
	prjInfo.teamId = Interactions.TEAM_ENEMY
	prj.prj_launch(prjInfo)

# func _fire_offset(spreadX:float, spreadY:float, _spinStart:float = 0, _spinRate:float = 0) -> void:
# 	var t:Transform = global_transform
# 	var offset:Vector3 = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, spreadX, spreadY)
# 	_fire_projectile(offset)

func _refresh_aim(target:Vector3) -> void:
	var forward:Vector3
	var calcAim:bool = !ignoreAimX || !ignoreAimX || !ignoreAimX
	if calcAim:
		look_at(target, Vector3.UP)
		var t:Transform = global_transform
		forward = -t.basis.z
		if ignoreAimX:
			forward.x = 0
		if ignoreAimY:
			forward.y = 0
		if ignoreAimZ:
			forward.z = 0
		forward = forward.normalized()
	else:
		var t:Transform = global_transform
		forward = -t.basis.z
	_aimForward = forward

# tell the turret to fire at a position manually instead
# of waiting for its timing
func immediate_fire(overridePrjInfo:PrjLaunchInfo) -> void:
	_refresh_aim(overridePrjInfo.target)
	_fire(overridePrjInfo)

func _fire(prjInfo:PrjLaunchInfo) -> void:
	_refireTick = refireRate
	_fire_projectile(prjInfo)
	# _fire_projectile(_aimForward, 45, projectileRollRate * _rollDir)
	# _fire_projectile(_aimForward, 90, projectileRollRate * _rollDir)
	# _fire_projectile(_aimForward, 135, projectileRollRate * _rollDir)
		
	if alternateRoll:
		_rollDir *= -1

func _process(_delta:float) -> void:
	if !_active:
		return
	var tar:Dictionary = Main.get_target()
	if tar.valid == false:
		return
	
	_refresh_aim(tar.position)
	
	if _refireTick <= 0:
		_fire(_prjInfo)
		
		# _fire_offset(-5000, 0)
		# _fire_offset(5000, 0)
		# var offset:Vector3 = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, 5000, 0)
		# _fire(offset)

		# offset = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, -5000, 0)
		# _fire(offset)
	else:
		_refireTick -= _delta
