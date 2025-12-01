extends Node

@onready var _anchor:Node3D = $anchor
@onready var _bg:Node3D = $cityscape

func _ready() -> void:
	_anchor.visible = false

func _process(_delta:float) -> void:
	var inv:Transform3D = _anchor.global_transform.inverse()
	_bg.global_transform = inv
