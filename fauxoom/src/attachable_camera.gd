extends Camera
class_name AttachableCamera

var _worldParent:Spatial = null
var _attachParent:Spatial = null

var _shaking:bool = false
var _shakeTick:float = 0.0
var _shakeOffset:Vector3 = Vector3()

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
		_kickDegrees = 1
		_kickTick = 0.0


func _process(_delta:float) -> void:
	_kickTick += _delta
	var weight:float = _kickTick / _kickDuration
	weight = ZqfUtils.clamp_float(weight, 0.0, 1.0)
	var rot:Vector3 = rotation_degrees
	rot.x = lerp(_kickDegrees, 0.0, weight)
	rotation_degrees = rot

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
