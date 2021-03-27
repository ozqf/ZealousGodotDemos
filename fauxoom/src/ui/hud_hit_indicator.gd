extends Control

const TIME_TO_LIVE = 1.0

var _playerYaw:float = 0
var _hitYaw:float = 0

var _ttl:float = 0.0

func _ready() -> void:
	add_to_group(Groups.PLAYER_GROUP_NAME)

func _update_rotation() -> void:
	var diff:float = _hitYaw - _playerYaw
	# 3D space rotation is anti-clockwise
	# but Control nodes are clockwise!
	rect_rotation = -diff

func spawn(playerYaw:float, attackDir:Vector3) -> void:
	# var hitYawDegrees:float = atan2(attackDir.x, attackDir.z)
	var hitYawDegrees:float = rad2deg(atan2(attackDir.x, attackDir.z))
	# hitYawDegrees += 180
	_playerYaw = playerYaw
	_hitYaw = hitYawDegrees
	_update_rotation()
	# print("Player hit - self yaw " + str(_playerYaw) + " hit yaw: " + str(_hitYaw))
	# print("Diff: " + str(_hitYaw - _playerYaw) + " indicator rotation " + str(_hitYaw - _playerYaw))
	_ttl = TIME_TO_LIVE

func player_status_update(_health:int, _yawDegrees:float) -> void:
	_playerYaw = _yawDegrees

func _process(_delta:float) -> void:
	_ttl -= _delta
	if _ttl <= 0:
		queue_free()
	else:
		_update_rotation()
