extends Spatial

var _spr_a1 = load("res://sprite_test/player_a1.png")
var _spr_a2a8 = load("res://sprite_test/player_a2_a8.png")
var _spr_a3a7 = load("res://sprite_test/player_a3_a7.png")
var _spr_a4a6 = load("res://sprite_test/player_a4_a6.png")
var _spr_a5 = load("res://sprite_test/player_a5.png")


func _ready() -> void:
	pass

func _process(_delta:float) -> void:
	var cam:Transform = game.get_camera_pos()
	var t:Transform = self.global_transform
	var yawDegrees:float = rotation_degrees.y
	var toDegrees:float = t.origin.angle_to(cam.origin)
