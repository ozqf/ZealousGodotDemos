extends Area
class_name ZqfVolumeScanner

var bodies = []
var areas = []

var total:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var _r
	_r = self.connect("area_entered", self, "_area_entered")
	_r = self.connect("area_exited", self, "_area_exited")
	_r = self.connect("body_entered", self, "_body_entered")
	_r = self.connect("body_exited", self, "_body_exited")
	pass # Replace with function body.

func _area_entered(area:Area) -> void:
	areas.push_back(area)
	total += 1

func _area_exited(area:Area) -> void:
	var i:int = areas.find(area)
	areas.remove(i)
	total -= 1

func _body_entered(body:Node) -> void:
	bodies.push_back(body)
	total += 1

func _body_exited(body:Node) -> void:
	var i:int = bodies.find(body)
	bodies.remove(i)
	total -= 1
