extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(Groups.PLAYER_GROUP_NAME)
	pass # Replace with function body.

func player_camera_moved(_body, _head) -> void:
	var t:Transform = _head.global_transform
	global_transform.basis = t.basis
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
