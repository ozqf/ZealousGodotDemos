extends Camera
class_name AttachableCamera

var _worldParent:Spatial = null
var _attachParent:Spatial = null

var _shaking:bool = false
var _shakeTick:float = 0.0
var _shakeDuration:float = 0.25
var _shakeOffset:Vector3 = Vector3()
var _shakeRecalcTick:float = 0.0
var _shakeRecalcWait:float = 1.0 / 15.0

var _kicked:bool = false
var _kickDegrees:float = 0.0
var _kickTick:float = 0.0
var _kickDuration:float = 0.15

func _ready() -> void:
	_worldParent = get_parent()
	add_to_group(Groups.HUD_GROUP_NAME)

func hud_play_weapon_shoot(
	_shootAnimName:String,
	_idleAnimName:String,
	_loop:bool = false,
	_akimbo:bool = false,
	_heaviness:float = 1.0):
	if _heaviness > 0.0:
		_kickDegrees = 2
		_kickTick = 0.0
		_shakeTick = 0.0
		_shakeDuration = 0.2

func _process(_delta:float) -> void:
	# tick gun kick
	_kickTick += _delta
	var weight:float = _kickTick / _kickDuration
	weight = ZqfUtils.clamp_float(weight, 0.0, 1.0)
	var rot:Vector3 = rotation_degrees
	rot.x = lerp(_kickDegrees, 0.0, weight)
	rotation_degrees = rot
	
	# tick screen shake
	_shakeTick += _delta
	_shakeRecalcTick += _delta
	if _shakeRecalcTick < _shakeRecalcWait:
		return
	weight = _shakeTick / _shakeDuration
	weight = ZqfUtils.clamp_float(weight, 0.0, 1.0)
	weight = 1 - weight
	var shakeX:float = rand_range(-0.1, 0.1) * weight
	var shakeY:float = rand_range(-0.1, 0.1) * weight
	var shakeZ:float = rand_range(-0.1, 0.1) * weight
	var offX:Vector3 = transform.basis.x * shakeX
	var offY:Vector3 = transform.basis.y * shakeY
	var offZ:Vector3 = transform.basis.z * shakeZ
	#_shakeOffset.x = rand_range(-0.1, 0.1) * weight
	#_shakeOffset.y = rand_range(-0.1, 0.1) * weight
	
	_shakeOffset = transform.basis.x * shakeX
	_shakeOffset += transform.basis.y * shakeY

	transform.origin = _shakeOffset

func attach_to(newParent:Spatial) -> void:
	if _attachParent != null:
		detach()
	_attachParent = newParent
	# reset local position
	_worldParent.remove_child(self)
	_attachParent.add_child(self)
	transform = Transform.IDENTITY
	var _f = _attachParent.connect("tree_exiting", self, "detach")

func detach() -> void:
	if _attachParent == null:
		return
	var t:Transform = _attachParent.global_transform
	_attachParent.remove_child(self)
	_attachParent.disconnect("tree_exiting", self, "detach")
	_attachParent = null
	_worldParent.add_child(self)
	global_transform = t
