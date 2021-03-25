extends Control

var _playerYaw:float = 0
var _hitYaw:float = 0

func spawn(playerYaw:float, hitYaw:float) -> void:
	_playerYaw = playerYaw
	_hitYaw = hitYaw

func update_player_yaw(playerYaw:float) -> void:
	_playerYaw = playerYaw

func _process(_delta:float) -> void:
	var degrees:float = 0
	rect_rotation = degrees
