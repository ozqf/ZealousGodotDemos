extends Camera
class_name AttachableCamera

var _worldParent:Spatial = null
var _attachParent:Spatial = null

var _attachMode:bool = true

var _shaking:bool = false
var _shakeTick:float = 0.0
var _shakeDuration:float = 0.25
var _shakeOffset:Vector3 = Vector3()
var _shakeRecalcTick:float = 0.0
var _shakeRecalcWait:float = 1.0 / 10.0
var _shakeStrength:float = 0.1

var _kicked:bool = false
var _kickDegrees:float = 0.0
var _kickTick:float = 0.0
var _kickDuration:float = 0.15

func _ready() -> void:
	_worldParent = get_parent()
	add_to_group(Groups.HUD_GROUP_NAME)
	add_to_group(Groups.GAME_GROUP_NAME)

func hud_play_weapon_shoot(
	_shootAnimName:String,
	_idleAnimName:String,
	_loop:bool = false,
	_akimbo:bool = false,
	_heaviness:float = 1.0):
	if _heaviness > 0.0:
		_kickDegrees = 2
		_kickTick = 0.0
		# shake(0.2, 1)

func game_explosion(_origin:Vector3, _strength:float) -> void:
	var pos:Vector3 = global_transform.origin
	var dist:float = _origin.distance_to(pos)
	var weight:float = dist / 25.0
	weight = ZqfUtils.clamp_float(weight, 0.0, 1.0)
	weight = 1.0 - weight
	shake(0.4 * weight, 0.3 * weight)

func shake(_duration:float, _strength:float) -> void:
	_shakeTick = 0.0
	_shakeStrength = _strength
	_shakeDuration = _duration

func _refresh_pos() -> void:
	if _attachMode && ZqfUtils.is_obj_safe(_attachParent):
		var t:Transform = _attachParent.global_transform
		self.global_transform = t
		#print("Cam pos " + str(t.origin))
	pass

func _physics_process(delta:float) -> void:
	_refresh_pos()

func _process(_delta:float) -> void:
	
	get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_CAMERA_UPDATE, global_transform.basis)

func _tick_gun_kick(_delta:float) -> void:
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
	if _shakeDuration > 0:
		weight = _shakeTick / _shakeDuration
		weight = ZqfUtils.clamp_float(weight, 0.0, 1.0)
		weight = 1 - weight
	else:
		weight = 0.0
	var offset:float = _shakeStrength * weight
	var shakeX:float = rand_range(-offset, offset) * weight
	var shakeY:float = rand_range(-offset, offset) * weight
	var shakeZ:float = rand_range(-offset, offset) * weight
	#var offX:Vector3 = transform.basis.x * shakeX
	#var offY:Vector3 = transform.basis.y * shakeY
	#var offZ:Vector3 = transform.basis.z * shakeZ
	
	_shakeOffset = transform.basis.x * shakeX
	_shakeOffset += transform.basis.y * shakeY

	transform.origin = _shakeOffset

	get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_CAMERA_UPDATE, global_transform.basis)

func attach_to(newParent:Spatial) -> void:
	if _attachParent != null:
		detach()
	current = true
	_attachParent = newParent

	# reset local position
	if _attachMode:
		_worldParent.remove_child(self)
		_attachParent.add_child(self)
		transform = Transform.IDENTITY
		var _f = _attachParent.connect("tree_exiting", self, "detach")

func detach() -> void:
	if _attachParent == null:
		return
	current = false
	if _attachMode:
		var t:Transform = _attachParent.global_transform
		_attachParent.remove_child(self)
		_attachParent.disconnect("tree_exiting", self, "detach")
		global_transform = t
		_worldParent.call_deferred("add_child", self)
		#_worldParent.add_child(self)
	_attachParent = null
