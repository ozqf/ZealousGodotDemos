extends Node

@onready var _path:Path3D = $Path3D
@onready var _follower:PathFollow3D = $Path3D/follower_1
@onready var _follower2:PathFollow3D = $Path3D/follower_2
@onready var _anchor:Node3D = $anchor
@onready var _bg:Node3D = $cityscape
@onready var _chaser:Node3D = $world/chaser
@onready var _city:Node3D = $cityscape
@export var speed:float = 150.0

var _chaserDriftP:Vector3 = Vector3()
var _chaserV:Vector3 = Vector3()

func _ready() -> void:
	_anchor.visible = false
	_city.visible = true
	_chaserDriftP = _chaser.global_position
	_set_new_drift_pos()

func _set_new_drift_pos() -> void:
	var horizontalMin:float = 2
	var horizontalMax:float = 4
	var verticalMax:float = 0.5
	var x0:float = 0.0
	var x1:float = 0.0
	if _chaserDriftP.x > 0.0:
		x0 = -horizontalMax
		x1 = -horizontalMin
	else:
		x0 = horizontalMin
		x1 = horizontalMax
	_chaserDriftP.x = randf_range(x0, x1)
	_chaserDriftP.y = randf_range(-verticalMax, verticalMax)
	#_chaserDriftP.z = 36

func _tick_chaser(_delta:float) -> void:
	var frames:int = Engine.get_physics_frames()
	var fps:int = Engine.physics_ticks_per_second
	var driftInterval:int = fps * 2
	#print("frames " + str(frames) + " interval: " + str(driftInterval))
	var distTar:float = 3
	if _chaser.global_position.distance_squared_to(_chaserDriftP) <= distTar * distTar:
	#if frames % driftInterval == 0:
		_set_new_drift_pos()
		#print(str(_chaserDriftP))
		pass
	#var p:Vector3 = _chaser.global_position.lerp(_chaserDriftP, 0.02)
	#_chaser.global_position = p
	var toward:Vector3 = _chaser.global_position.direction_to(_chaserDriftP)
	var accel:float = 5.5 if _chaserV.dot(toward) > 0.0 else 12.0
	_chaserV += toward * accel * _delta
	_chaserV.z = _chaserDriftP.z
	var newChaserP:Vector3 = _chaser.global_position + _chaserV * _delta
	newChaserP.z = _chaserDriftP.z
	_chaser.global_position = newChaserP
	var curRoll:float = _chaser.rotation_degrees.z
	var tarRoll:float = _follower2.rotation_degrees.z
	var newRoll:float = lerp(curRoll, tarRoll, 0.01)
	#var newRoll:float = _follower2.rotation_degrees.z
	_chaser.rotation_degrees = Vector3(0, 0, newRoll)
	pass

func _process(_delta:float) -> void:
	#var numPoints:int = _path.curve.point_count
	#_path.curve.get_point_position()

	# background
	var mode:int = 0
	
	match mode:
		1:
			_follower.progress += speed * _delta
			_follower2.progress = _follower.progress - 20.0
			#var mid:Transform3D = _follower.global_transform.interpolate_with(_follower2.global_transform, 0.1)
			#_anchor.global_transform = _anchor.global_transform.interpolate_with(_follower.global_transform, 0.01)
			#_anchor.global_transform = mid
			
			
			_anchor.global_transform = _follower.global_transform
			var inv:Transform3D = _anchor.global_transform.inverse()
			#var inv:Transform3D = _anchor.global_transform.inverse()
			_bg.global_transform = inv
		0, _:
			_follower.progress += speed * _delta
			_follower2.progress = _follower.progress - 60

			var anchorT:Transform3D = _anchor.global_transform
			var newT:Transform3D = anchorT.interpolate_with(_follower.global_transform, 0.01)
			newT.origin = _follower.global_position
			_anchor.global_transform = newT
			
			var inv:Transform3D = _anchor.global_transform.inverse()
			_bg.global_transform = inv
	_tick_chaser(_delta)

func _physics_process(_delta: float) -> void:
	#print("progress 1: " + str(_follower.progress) + " progress 2: " + str(_follower2.progress))
	pass
