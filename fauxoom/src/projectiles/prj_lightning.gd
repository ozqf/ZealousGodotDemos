extends Node3D

@onready var _scanner:Area3D = $Area
var _bodies = []
var _areas = []
var _hasFired:bool = false
var _tick:float = 0
var _ticks:int = 0
@export var lifeTime:float = 1.5
var _hitInfo:HitInfo = null
var _beamEnd:Vector3 = Vector3()

func _ready():
	_scanner.connect("body_entered", _on_body_entered)
	_scanner.connect("area_entered", _on_area_entered)
	_scanner.connect("body_exited", _on_body_exited)
	_scanner.connect("area_exited", _on_area_exited)
	_hitInfo = Game.new_hit_info()
	_hitInfo.damage = 200
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_SUPER_RAIL
	_hitInfo.comboType = Interactions.COMBO_CLASS_RAILGUN
	_hitInfo.attackTeam = Interactions.TEAM_PLAYER
	_hitInfo.hyperLevel = 1
	pass # Replace with function body.

func _on_body_entered(_body:PhysicsBody3D) -> void:
	# if !_isScanning:
	# 	return
	#print("Lightning found body")
	_bodies.push_back(_body)

func _on_body_exited(_body) -> void:
	#print("Lightning lost body")
	var i:int = _bodies.find(_body)
	_bodies.remove(i)

func _on_area_entered(_area:Area3D) -> void:
	# if !_isScanning:
	# 	return
	#print("Lightning found area")
	_areas.push_back(_area)

func _on_area_exited(_area:Area3D) -> void:
	#print("Lightning lost area")
	var i:int = _areas.find(_area)
	_areas.remove(i)

func _run_hits() -> void:
	# _hitInfo.hyperLevel = Game.hyperLevel
	#print("Lightning hitting " + str(_bodies.size()) + " bodies and " + str(_areas.size()) + " areas")
	var positions = []
	var origin:Vector3 = global_transform.origin
	var heightOffset:Vector3 = Vector3(0, 1, 0)
	positions.push_back(origin)
	for body in _bodies:
		var dest:Vector3 = body.global_transform.origin
		# Game.get_factory().draw_trail(origin, dest)
		Game.get_factory().spawn_blood_spurt(dest)
		if Interactions.hit(_hitInfo, body) > 0:
			positions.push_back(dest + heightOffset)
	for area in _areas:
		var dest:Vector3 = area.global_transform.origin
		# Game.get_factory().draw_trail(origin, dest)
		Game.get_factory().spawn_blood_spurt(dest)
		if Interactions.hit(_hitInfo, area) > 0:
			positions.push_back(dest + heightOffset)
	pass
	positions.push_back(_beamEnd)
	var numPositions:int = positions.size()
	for i in range(0, numPositions - 1):
		var a:Vector3 = positions[i]
		var b:Vector3 = positions[i + 1]
		Game.get_factory().draw_trail(a, b)

func _process(_delta):
	_tick += _delta
	_ticks += 1
	if !_hasFired && (_bodies.size() > 0 || _areas.size() > 0):
		_hasFired = true
		_run_hits()
	if _tick > lifeTime:
		queue_free()

func spawn(t:Transform3D, beamLength:float) -> void:
	global_transform = t
	_beamEnd = t.origin + (-t.basis.z * beamLength)
	var shaftWidth:float = 0.15
	$MeshInstance3D.scale = Vector3(shaftWidth, beamLength, shaftWidth)
	$MeshInstance3D.transform.origin = Vector3(0.0, 0.0, -(beamLength / 2))

	$MeshInstance2.scale = Vector3(shaftWidth, beamLength, shaftWidth)
	$MeshInstance2.transform.origin = Vector3(0.0, 0.0, -(beamLength / 2))

	# move meshes slightly so they're not directly in the player's eyes!
	$MeshInstance3D.transform.origin -= t.basis.y * 0.1
	$MeshInstance2.transform.origin -= t.basis.y * 0.1
	var box:BoxShape3D = BoxShape3D.new()
	box.extents = Vector3(1.0, beamLength, 1.0)
	$Area/CollisionShape.shape = box
