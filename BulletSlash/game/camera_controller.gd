extends Node3D

@onready var _cameraRoot:Node3D = $camera_root
@onready var _camera:Camera3D = $camera_root/Camera3D
@onready var _navRegion:NavigationRegion3D = $NavigationRegion3D
@onready var _navAgent:NavigationAgent3D = $camera_root/NavigationAgent3D

var _origin:Vector3
var _subjectPos:Vector3
var _trackingPosition:Vector3 = Vector3()

func _ready():
	self.add_to_group(HudInfo.GROUP_NAME)
	var t:Transform3D = _camera.global_transform
	_origin = t.origin
	_subjectPos = _origin + -t.basis.z
	_trackingPosition = _origin

func hud_info_broadcast(hudInfo:HudInfo) -> void:
	_subjectPos = hudInfo.playerWorldPosition

func _physics_process(_delta) -> void:
	#NavigationServer3D.is
	var mapId:RID = NavigationServer3D.get_maps()[0]
	var queryPos:Vector3 = _subjectPos
	queryPos.y = _cameraRoot.global_position.y
	if NavigationServer3D.map_is_active(mapId):
		var pos:Vector3 = NavigationServer3D.map_get_closest_point(mapId, queryPos)
		_navAgent.target_position = pos
		#print("Subject pos " + str(_subjectPos) + " nearest track pos " + str(pos))

func tilt_camera_to_target(targetPos:Vector3) -> void:
	var target:TargetInfo = Game.get_player_target()
	var pitch:float = -50.0
	if target != null:
		_subjectPos = target.t.origin
		#var cam:Transform3D = _cameraRoot.global_transform
		var toTarget:Vector3 = _camera.global_position.direction_to(targetPos)
		toTarget.x = 0.0
		pitch = atan2(toTarget.y, -toTarget.z) * ZqfUtils.RAD2DEG
		#print(pitch)
		#pitch = clampf(pitch, -90, 90)
	
	_camera.rotation_degrees = Vector3(pitch, 0, 0)
	#_camera.look_at(targetPos, Vector3.UP)

func _process(delta):
	# navigate tracking point
	if !_navAgent.is_navigation_finished():
		var nextPos:Vector3 = _navAgent.get_next_path_position()
		var newVelocity:Vector3 = _trackingPosition.direction_to(nextPos) * 10.0
		_trackingPosition += newVelocity * delta
	#else:
	#	print("Stopped")
	# lerp camera to tracking point
	var pos:Vector3 = _cameraRoot.global_position.lerp(_trackingPosition, 0.1)
	#pos.y = _origin.y
	_cameraRoot.global_position = pos
	tilt_camera_to_target(_subjectPos)
