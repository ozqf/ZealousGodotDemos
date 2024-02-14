extends Node3D

@onready var _worldScanner:Area3D = $Area3D
@onready var _label:Label3D = $Label3D

@onready var _rayLeft:RayCast3D = $ray_left_root/ray_left
@onready var _rayRight:RayCast3D = $ray_right_root/ray_right

@onready var _beamLimb1 = $BeamLimb1
@onready var _beamLimb2 = $BeamLimb2

func _ready():
	pass

func _quick_move(delta) -> void:
	var inputDir:Vector3 = Vector3.ZERO
	if Input.is_action_pressed("ui_left"):
		inputDir.z += 1
	if Input.is_action_pressed("ui_right"):
		inputDir.z -= 1
	self.global_position += (inputDir * 5) * delta

func _process(delta):
	_quick_move(delta)
	
	var txt:String = ""
	var l:int = _worldScanner.get_overlapping_bodies().size()
	txt += "Bodies found " + str(l) + "\n"
	
	txt += _rayLeft.get_debug_text()
	
	if _beamLimb1.is_active():
		var distSqr:float = _beamLimb1.get_dist_sqr()
		txt += "Limb 1 dist: " + str(distSqr) + "\n"
		if distSqr > 16.0:
			if _rayLeft.is_colliding():
				_beamLimb1.set_target(_rayLeft.best)
	elif _rayLeft.is_colliding():
		_beamLimb1.set_target(_rayLeft.best)
	
	if _rayRight.is_colliding():
		_beamLimb2.set_target(_rayRight.best)
	
	_label.text = txt
