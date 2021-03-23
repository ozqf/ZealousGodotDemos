extends Spatial
class_name SpriteObject

onready var _sprite:Sprite3D = $Sprite3D

var _spr_a1 = load("res://assets/sprites/player/player_a1.png")
var _spr_a2a8 = load("res://assets/sprites/player/player_a2_a8.png")
var _spr_a3a7 = load("res://assets/sprites/player/player_a3_a7.png")
var _spr_a4a6 = load("res://assets/sprites/player/player_a4_a6.png")
var _spr_a5 = load("res://assets/sprites/player/player_a5.png")
var _spr_a6 = load("res://assets/sprites/player/player_a6.png")
var _spr_a7 = load("res://assets/sprites/player/player_a7.png")
var _spr_a8 = load("res://assets/sprites/player/player_a8.png")

var _frames = []

export var useParentYaw:bool = false

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
	degrees -= 360.0 / (numIndices * 2)
	while (degrees < 0):
		degrees += 360
	while (degrees >= 360):
		degrees -= 360
	# flip
	degrees = 360 - degrees
	#var step:float = 360 / numIndices
	return int(floor((degrees / 360) * numIndices))

func _process(_delta:float) -> void:
	# _old_update_sprite()
	var yaw:float = 0
	if useParentYaw:
		yaw = get_parent().rotation_degrees.y
	else:
		yaw = rotation_degrees.y
	var i:int = ZqfUtils.sprite_index(Main.get_camera_pos(), self.global_transform, yaw, _frames.size())
	_sprite.texture = _frames[i]
