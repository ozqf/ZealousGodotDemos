extends Camera3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(Groups.PLAYER_GROUP_NAME)
	add_to_group(Groups.GAME_GROUP_NAME)
	pass # Replace with function body.

func player_camera_moved(_body, _head) -> void:
	# var t:Transform3D = _head.global_transform
	# global_transform.basis = t.basis
	# fov = Config.cfg.r_fov
	pass

func game_camera_update(_basis:Basis) -> void:
	global_transform.basis = _basis
	fov = Config.cfg.r_fov

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
