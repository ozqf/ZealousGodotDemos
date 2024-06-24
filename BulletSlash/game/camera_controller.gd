extends Node3D

@onready var _cameraRoot:Node3D = $camera_root
@onready var _navRegion:NavigationRegion3D = $NavigationRegion3D
@onready var _navAgent:NavigationAgent3D = $camera_root/NavigationAgent3D
#@onready var _trackRoot:Node3D = $camera_track

var _origin:Vector3
var _subjectPos:Vector3
var _trackingPosition:Vector3 = Vector3()

func _ready():
	self.add_to_group(HudInfo.GROUP_NAME)
	_origin = _cameraRoot.global_position
	_subjectPos = _origin
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
