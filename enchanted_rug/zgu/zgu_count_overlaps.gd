extends Area
class_name ZqfCountOverlaps

var _bodies:int = 0
var _areas:int = 0

func _ready() -> void:
    var _result
    _result = connect("area_entered", self, "_on_area_entered")
    _result = connect("area_exited", self, "_on_area_exited")
    _result = connect("body_entered", self, "_on_body_entered")
    _result = connect("body_exited", self, "_on_body_exited")

func _on_area_entered(_area:Area) -> void:
    _areas += 1

func _on_area_exited(_area:Area) -> void:
    _areas -= 1

func _on_body_entered(_body:Node) -> void:
    _bodies += 1

func _on_body_exited(_body:Node) -> void:
    _bodies -= 1

func total_overlaps() -> int:
    return _bodies + _areas
