extends Area
class_name InstantAreaScan

signal scan_result(bodies)

export var showVolume:bool = false

onready var _collisionShape:CollisionShape = $CollisionShape

# var _on:bool = false
var _ticks:int = -1
var _bodies = []

func _ready() -> void:
	var _r = connect("body_entered", self, "_body_entered")

func run() -> void:
	_ticks = 2
	#if showVolume:
	#	$MeshInstance.visible = true
	# _collisionShape.disabled = false
	#var _r = connect("body_entered", self, "_body_entered")

func _process(_delta) -> void:
	if _ticks == -1:
		return
	if _ticks > 0:
		_ticks -= 1
		return
	_ticks = -1
	#$MeshInstance.visible = false
	# _collisionShape.disabled = true
	var result = _bodies
	_bodies = []
	emit_signal("scan_result", result)
	
func _body_entered(body) -> void:
	_bodies.push_back(body)
