extends Spatial

onready var _sprite:Sprite3D = $Sprite3D

var _spr_a1 = load("res://sprite_test/player_a1.png")
var _spr_a2a8 = load("res://sprite_test/player_a2_a8.png")
var _spr_a3a7 = load("res://sprite_test/player_a3_a7.png")
var _spr_a4a6 = load("res://sprite_test/player_a4_a6.png")
var _spr_a5 = load("res://sprite_test/player_a5.png")
var _spr_a6 = load("res://sprite_test/player_a6.png")
var _spr_a7 = load("res://sprite_test/player_a7.png")
var _spr_a8 = load("res://sprite_test/player_a8.png")

var _frames = []

func _ready() -> void:
	_frames.push_back(_spr_a1) # 0
	_frames.push_back(_spr_a2a8)
	_frames.push_back(_spr_a3a7)
	_frames.push_back(_spr_a4a6)
	_frames.push_back(_spr_a5) # 4
	_frames.push_back(_spr_a6)
	_frames.push_back(_spr_a7)
	_frames.push_back(_spr_a8)
	pass

func _cap_degrees(degrees:float) -> float:
	while degrees >= 360:
		degrees -= 360
	while degrees < 0:
		degrees += 360
	return degrees

func _calc_angle_index(degrees:float, numIndices:int) -> int:
	if numIndices <= 0:
		return 0
	while (degrees < 0):
		degrees += 360
	while (degrees >= 360):
		degrees -= 360
	# flip
	degrees = 360 - degrees
	#var step:float = 360 / numIndices
	return int(floor((degrees / 360) * numIndices))

func _process(_delta:float) -> void:
	var camT:Transform = game.get_camera_pos()
	var selfT:Transform = self.global_transform
	var camPos:Vector3 = camT.origin
	var selfPos:Vector3 = selfT.origin
	var yawDegrees:float = rotation_degrees.y
	#var toDegrees:float = selfT.origin.angle_to(camT.origin)
	#var toDegrees:float = atan2(camT.origin.y - selfT.origin.y, camT.origin.x - selfT.origin.x)
	#var toDegrees:float = atan2(selfPos.z - camPos.z, selfPos.x - camPos.x)
	var toDegrees:float = atan2(camPos.z - selfPos.z, camPos.x - selfPos.x)
	toDegrees = rad2deg(toDegrees)
	toDegrees += 90
	toDegrees = _cap_degrees(toDegrees)
	
	game.debugV3_1 = camT.origin
	game.debugV3_2 = selfT.origin
	game.debugDegrees = toDegrees
	
	var i:int = _calc_angle_index(toDegrees, _frames.size())
	game.debug_int = i
	_sprite.texture = _frames[i]
