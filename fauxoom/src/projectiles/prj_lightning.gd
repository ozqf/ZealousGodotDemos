extends Spatial

onready var _scanner:Area = $Area
var _bodies = []
var _areas = []
var _hasFired:bool = false
var _tick:float = 0
var _ticks:int = 0
export var lifeTime:float = 1.5
var _hitInfo:HitInfo = null

func _ready():
	_scanner.connect("body_entered", self, "_on_body_entered")
	_scanner.connect("area_entered", self, "_on_area_entered")
	_scanner.connect("body_exited", self, "_on_body_exited")
	_scanner.connect("area_exited", self, "_on_area_exited")
	_hitInfo = Game.new_hit_info()
	_hitInfo.damage = 200
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_PLASMA
	_hitInfo.attackTeam = Interactions.TEAM_PLAYER
	pass # Replace with function body.

func _on_body_entered(_body:PhysicsBody) -> void:
	# if !_isScanning:
	# 	return
	print("Lightning found body")
	_bodies.push_back(_body)

func _on_body_exited(_body) -> void:
	print("Lightning lost body")
	var i:int = _bodies.find(_body)
	_bodies.remove(i)

func _on_area_entered(_area:Area) -> void:
	# if !_isScanning:
	# 	return
	print("Lightning found area")
	_areas.push_back(_area)

func _on_area_exited(_area:Area) -> void:
	print("Lightning lost area")
	var i:int = _areas.find(_area)
	_areas.remove(i)

func _run_hits() -> void:
	_hitInfo.hyperLevel = Game.hyperLevel
	print("Lightning hitting " + str(_bodies.size()) + " bodies and " + str(_areas.size()) + " areas")
	for body in _bodies:
		Interactions.hit(_hitInfo, body)
	for area in _areas:
		Interactions.hit(_hitInfo, area)
	pass

func _process(_delta):
	_tick += _delta
	_ticks += 1
	if !_hasFired && (_bodies.size() > 0 || _areas.size() > 0):
		_hasFired = true
		_run_hits()
	if _tick > lifeTime:
		queue_free()

func spawn(t:Transform, beamLength:float) -> void:
	global_transform = t
	$MeshInstance.scale = Vector3(0.25, beamLength, 0.25)
	$MeshInstance.transform.origin = Vector3(0.0, 0.0, -(beamLength / 2))
	var box:BoxShape = BoxShape.new()
	box.extents = Vector3(1.0, beamLength, 1.0)
	$Area/CollisionShape.shape = box
