extends Control
class_name Hud

@onready var _shotCount:Label = $shot_count_label

func _ready():
	self.add_to_group(HudInfo.GROUP_NAME)

func hud_info_broadcast(hudInfo:HudInfo) -> void:
	
	#_shotCount.text = "SHOTS: " + str(hudInfo.shotCount)
	_shotCount.text = str(hudInfo.shotCount)
	var viewPort:Viewport = get_viewport()
	var cam:Camera3D = viewPort.get_camera_3d()
	var labelPos:Vector2 = world_point_to_screen(
		hudInfo.playerWorldPosition,
		cam)
	_shotCount.position = labelPos

func world_point_to_screen(pos:Vector3, camera:Camera3D) -> Vector2:
	#var pos:Vector3 = self.global_transform.origin
	var scrPos:Vector2 = camera.unproject_position(pos)
	scrPos.y += 64
	return scrPos

