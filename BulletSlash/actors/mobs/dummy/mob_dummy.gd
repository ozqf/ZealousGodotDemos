extends MobBase

var _bounceTick:float = 1.0
var _bounceTime:float = 1.0

var _bounceDisplayT:Transform3D
var _originDisplayT:Transform3D

func _ready() -> void:
	_originDisplayT = _display.transform

func hit(_hitInfo) -> int:
	#print("Mob dummy hit")
	_bounceTick = 0.0
	_bounceTime = 0.5
	_bounceDisplayT = _originDisplayT
	var bounceAxis:Vector3 = _hitInfo.direction.cross(Vector3.UP).normalized()
	_bounceDisplayT = _bounceDisplayT.rotated(bounceAxis, deg_to_rad(45.0))
	# TODO: Nothing culls gfx objects yet!
	var gfxDir:Vector3 = _hitInfo.direction
	gfxDir.y = 0
	gfxDir = gfxDir.normalized()
	var gfxPos:Vector3 = self.global_position
	gfxPos.y += 1
	gfxPos = gfxPos.lerp(_hitInfo.position, 0.5)
	if _hitInfo.damageType == Game.DAMAGE_TYPE_SLASH:
		var gfx = Game.spawn_gfx_blade_blood_spurt(gfxPos, gfxDir)
	else:
		Game.spawn_gfx_punch_blood_spurt(gfxPos)
	return 1

func _process(_delta:float) -> void:
	_bounceTick += _delta
	_bounceTick = clampf(_bounceTick, 0, _bounceTime)
	var weight:float = _bounceTick / _bounceTime
	_display.transform = _bounceDisplayT.interpolate_with(_originDisplayT, weight)
	pass
